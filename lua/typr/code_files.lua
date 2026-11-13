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


local expand_tabs = function(line)
  return (line:gsub("\t", "    "))
end

local is_scope = function(type)
  return not type:find "call"
    and (type:find "function" or type:find "method" or type:find "class" or type:find "struct" or type:find "impl")
end

-- first rows (1-based) of functions and classes
local ts_starts = function(text, ft)
  local lang = vim.treesitter.language.get_lang(ft) or ft

  if not pcall(vim.treesitter.language.add, lang) then
    return nil
  end

  local ok, parser = pcall(vim.treesitter.get_string_parser, text, lang)

  if not ok then
    return nil
  end

  local root = parser:parse()[1]:root()
  local starts = {}

  local add = function(node)
    local sr, _, er = node:range()

    if er > sr then
      table.insert(starts, sr + 1)
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

  if #starts == 0 then
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

  return starts
end

-- without a parser: unindented lines after a blank line, which is where
-- top-level definitions usually start
local indent_starts = function(lines)
  local starts = {}

  for i, line in ipairs(lines) do
    local prev_blank = i == 1 or not lines[i - 1]:find "%S"
    local starts_def = line:find "^[%a_]" ~= nil

    if prev_blank and starts_def and lines[i + 1] and lines[i + 1]:find "%S" then
      table.insert(starts, i)
    end
  end

  return starts
end

-- a reading position: { file, lines (of the file), row, piece, base }, where
-- piece is the part of a wrapped row to go on from and base the indentation
-- removed, kept from test to test so the code stays lined up as it carries on

-- a function or class in a random file, to start reading at
local pick_start = function(files)
  for _ = 1, 20 do
    local file = files[math.random(1, #files)]
    local text = read(file.path)

    if text then
      local lines = vim.split(text, "\n")
      local starts = ts_starts(text, file.ft)

      if not starts or #starts == 0 then
        starts = indent_starts(lines)
      end

      if #starts > 0 then
        local row = starts[math.random(1, #starts)]
        local base = #expand_tabs(lines[row]):match "^ *"
        return { file = file, lines = lines, row = row, piece = 1, base = base }
      end
    end
  end
end

-- splits a line wider than the typing area at spaces, continuing on lines
-- indented a bit more, so no code is left out
local wrap = function(text, width)
  local pieces = {}
  local indent = #text:match "^ *"
  local cont = string.rep(" ", indent + 4 <= width / 2 and indent + 4 or indent)

  while #text > width do
    local lead = #text:match "^ *"
    local cut -- last space that fits, after the indentation

    for i = width + 1, lead + 2, -1 do
      if text:sub(i, i) == " " then
        cut = i
        break
      end
    end

    local head, rest

    if cut then
      head, rest = text:sub(1, cut - 1), text:sub(cut + 1)
    else
      head, rest = text:sub(1, width), text:sub(width + 1)
    end

    table.insert(pieces, (head:gsub("%s+$", "")))
    text = cont .. (rest:gsub("^%s+", ""))
  end

  table.insert(pieces, text)
  return pieces
end

-- up to `want` lines read on from pos, dedented by the base indentation (or
-- less, when the code goes further left). blank lines and
-- lines with non-ASCII characters are skipped, too wide lines wrapped.
-- returns the lines, where reading stopped and the row of the first line
local take = function(pos, want, width)
  local lines = pos.lines
  local raw = {}
  local base = pos.base
  local r = pos.row

  -- every row gives at least one line, so `want` rows are enough
  while r <= #lines and #raw < want do
    local line = expand_tabs(lines[r]):gsub("%s+$", "")

    if line ~= "" and not line:find "[^\32-\126]" then
      local indent = #line:match "^ *"
      base = math.min(base, indent)
      table.insert(raw, { row = r, text = line })
    end

    r = r + 1
  end

  local out = {}
  local stop = { file = pos.file, lines = lines, row = r, piece = 1, base = base }

  for i, l in ipairs(raw) do
    local text = l.text:sub(base + 1)

    -- nested too deep to fit in a readable way
    if #text:match "^ *" < width / 2 then
      local pieces = wrap(text, width)

      for p = (i == 1 and pos.piece or 1), #pieces do
        if #out == want then
          stop.row, stop.piece = l.row, p
          return out, stop, raw[1].row
        end

        table.insert(out, pieces[p])
      end
    end
  end

  return out, stop, raw[1] and raw[1].row
end

-- where the code is being read from, kept between tests so each one carries
-- on from where the last one stopped: { key, start = pos, stop = pos }
local reading

-- `want` lines of code and where they come from ("file:row"), or nil
-- how: "same" types the current test again (also used for the first one),
-- "next" goes on from where it stopped, "jump" starts somewhere new
M.gen_lines = function(paths, filetypes, want, width, how)
  local files = M.list_files(paths, filetypes)

  if #files == 0 then
    return nil
  end

  local key = table.concat(paths, "\0") .. "\0" .. table.concat(filetypes or {}, ",")

  if not reading or reading.key ~= key or how == "jump" then
    local start = pick_start(files)

    if not start then
      return nil
    end

    reading = { key = key, start = start, stop = start }
  elseif how == "next" then
    reading.start = reading.stop
  end

  local lines, source = {}, nil
  local pos = reading.start

  for _ = 1, 20 do
    local chunk, stop, row = take(pos, want - #lines, width)

    if #chunk > 0 and not source then
      source = pos.file.name .. ":" .. row
      reading.start = pos
    end

    vim.list_extend(lines, chunk)
    pos = stop

    if #lines >= want then
      break
    end

    -- end of the file, go on in another one
    pos = pick_start(files)

    if not pos then
      break
    end
  end

  if #lines < want then
    return nil
  end

  reading.stop = pos
  return lines, source
end

return M
