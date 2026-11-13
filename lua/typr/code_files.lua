-- code mode lines taken from files on disk instead of the built-in snippets.
-- typing starts at "good spots": functions and classes found with treesitter
-- (the textobjects queries when installed, node types otherwise), or at
-- top-level lines after a blank line for languages without a parser
local M = {}

local skip_dirs = {
  node_modules = true,
  build = true,
  dist = true,
  target = true,
  vendor = true,
  out = true,
  bin = true,
  obj = true,
  __pycache__ = true,
}

-- filetypes typed by default (programming languages), when no
-- `code.filetypes` is given
local code_fts = {}

for _, ft in ipairs {
  "ada", "asm", "bash", "c", "clojure", "cmake", "cpp", "cs", "css", "cuda",
  "d", "dart", "elixir", "elm", "erlang", "fennel", "fish", "fortran",
  "fsharp", "gdscript", "glsl", "go", "haskell", "hlsl", "html", "java",
  "javascript", "javascriptreact", "julia", "kotlin", "lisp", "lua", "make",
  "nim", "nix", "objc", "objcpp", "ocaml", "odin", "perl", "php", "python",
  "r", "racket", "ruby", "rust", "scala", "scheme", "scss", "sh", "sql",
  "svelte", "swift", "typescript", "typescriptreact", "verilog", "vhdl", "vim",
  "vue", "wgsl", "zig", "zsh",
} do
  code_fts[ft] = true
end

local max_files = 5000
local max_file_size = 512 * 1024

local cache = {} -- file list per paths

-- files under the given paths (dirs are searched recursively)
M.list_files = function(paths, filetypes)
  local key = table.concat(paths, "\0") .. "\0" .. table.concat(filetypes or {}, ",")

  if cache[key] then
    return cache[key]
  end

  local wanted = code_fts

  if filetypes then
    wanted = {}

    for _, ft in ipairs(filetypes) do
      wanted[ft] = true
    end
  end

  local files = {}

  -- name: shown as the source of the code, relative to the given path
  local add = function(file, name)
    local ft = vim.filetype.match { filename = file }

    if ft and wanted[ft] then
      table.insert(files, { path = file, name = name, ft = ft })
    end
  end

  for _, p in ipairs(paths) do
    local root = vim.fs.normalize(vim.fn.expand(p))
    local stat = vim.uv.fs_stat(root)

    if stat and stat.type == "file" then
      add(root, vim.fs.basename(root))
    elseif stat and stat.type == "directory" then
      local walk = vim.fs.dir(root, {
        depth = 20,
        skip = function(name)
          return not skip_dirs[name] and name:sub(1, 1) ~= "."
        end,
      })

      for name, type in walk do
        if #files >= max_files then
          break
        end

        if type == "file" and name:sub(1, 1) ~= "." then
          add(root .. "/" .. name, name)
        end
      end
    end
  end

  cache[key] = files
  return files
end

local read = function(path)
  local stat = vim.uv.fs_stat(path)

  if not stat or stat.size > max_file_size then
    return nil
  end

  local f = io.open(path, "rb")

  if not f then
    return nil
  end

  local text = f:read "*a"
  f:close()

  -- binary files
  if text:find "%z" then
    return nil
  end

  return text
end

local is_scope = function(type)
  return not type:find "call"
    and (type:find "function" or type:find "method" or type:find "class" or type:find "struct" or type:find "impl")
end

-- {start_row, end_row} (1-based) of functions and classes
local ts_ranges = function(text, ft)
  local lang = vim.treesitter.language.get_lang(ft) or ft

  if not pcall(vim.treesitter.language.add, lang) then
    return nil
  end

  local ok, parser = pcall(vim.treesitter.get_string_parser, text, lang)

  if not ok then
    return nil
  end

  local root = parser:parse()[1]:root()
  local ranges = {}

  local add = function(node)
    local sr, _, er = node:range()

    if er > sr then
      table.insert(ranges, { sr + 1, er + 1 })
    end
  end

  local qok, query = pcall(vim.treesitter.query.get, lang, "textobjects")

  if qok and query then
    for id, node in query:iter_captures(root, text) do
      local name = query.captures[id]

      if name == "function.outer" or name == "class.outer" then
        add(node)
      end
    end
  end

  if #ranges == 0 then
    local walk

    walk = function(node)
      for child in node:iter_children() do
        if child:named() then
          if is_scope(child:type()) then
            add(child)
          end

          walk(child)
        end
      end
    end

    walk(root)
  end

  return ranges
end

-- without a parser: unindented lines after a blank line, which is where
-- top-level definitions usually start
local indent_ranges = function(lines)
  local ranges = {}

  for i, line in ipairs(lines) do
    local prev_blank = i == 1 or not lines[i - 1]:find "%S"
    local starts_def = line:find "^[%a_]" ~= nil

    if prev_blank and starts_def and lines[i + 1] and lines[i + 1]:find "%S" then
      table.insert(ranges, { i, #lines })
    end
  end

  return ranges
end

local expand_tabs = function(line)
  return (line:gsub("\t", "    "))
end

-- typeable lines of rows s..e, dedented to the first line. stops at a line
-- that cant be typed so the code keeps reading naturally, and when the code
-- goes left of the first line, as that leaves the scope it started in
local take = function(lines, s, e, want, width)
  local out = {}
  local base

  for r = s, e do
    local line = expand_tabs(lines[r]):gsub("%s+$", "")

    if line ~= "" then
      local indent = #line:match "^ *"
      base = base or indent

      if indent < base then
        break
      end

      line = line:sub(base + 1)

      if #line > width or line:find "[^\32-\126]" then
        break
      end

      table.insert(out, line)

      if #out == want then
        break
      end
    end
  end

  return out
end

-- picks chunks from random files until there are `want` lines
-- returns lines and where the first chunk came from, or nil
M.gen_lines = function(paths, filetypes, want, width)
  local files = M.list_files(paths, filetypes)

  if #files == 0 then
    return nil
  end

  local lines, source = {}, nil
  local current -- file the test started in, preferred for more lines
  local used = {} -- starting points already in this test

  for attempt = 1, 50 do
    if #lines >= want then
      break
    end

    -- stay in the same file for a few tries so the test doesnt jump around
    local file = (current and attempt <= 10) and current or files[math.random(1, #files)]
    local text = read(file.path)

    if text then
      local flines = vim.split(text, "\n")
      local ranges = ts_ranges(text, file.ft)

      if not ranges or #ranges == 0 then
        ranges = indent_ranges(flines)
      end

      if #ranges > 0 then
        local range = ranges[math.random(1, #ranges)]
        local id = file.path .. ":" .. range[1]
        -- start at a function/class and keep reading the file from there
        local chunk = take(flines, range[1], #flines, want - #lines, width)

        -- a chunk should give at least a couple of lines to be worth it
        if not used[id] and #chunk >= math.min(2, want - #lines) then
          used[id] = true
          source = source or (file.name .. ":" .. range[1])
          current = current or file
          vim.list_extend(lines, chunk)
        end
      end
    end
  end

  if #lines < want then
    return nil
  end

  return lines, source
end

return M
