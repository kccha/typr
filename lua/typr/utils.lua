local M = {}
local state = require "typr.state"
local words = require "typr.constants.words"
local phrases = require "typr.constants.phrases"
local volt = require "volt"

local symbols = {
  "!",
  '"',
  "#",
  "$",
  "%",
  "&",
  "'",
  "(",
  ")",
  "*",
  "+",
  ",",
  "-",
  ".",
  "/",
  ":",
  ";",
  "<",
  "=",
  ">",
  "?",
  "@",
  "[",
  "\\",
  "]",
  "^",
  "_",
  "`",
  "{",
  "|",
  "}",
  "~",
}

local punct_symbolslen = #symbols

local gen_random_word = function()
  local word = ""
  local length = math.random(1, 7)

  for _ = 1, length do
    local randomChar = string.char(math.random(97, 122))
    word = word .. randomChar
  end

  return word
end

M.gen_word = function()
  local word
  local frequency = math.random(1, 4)
  local config = state.config
  local wordslen = #words

  if frequency == 4 and state.config.numbers then
    word = tostring(math.random(1, 1000))
  else
    word = config.random and gen_random_word() or words[math.random(1, wordslen)]
  end

  if state.config.symbols then
    local tmp_i = math.random(0, punct_symbolslen)
    local symbol = tmp_i > 0 and symbols[tmp_i] or ""
    word = word .. symbol
  end

  return word
end

M.words_to_lines = function()
  local lines = {}
  local maxw = state.w_with_pad

  for i = 1, state.linecount do
    local lineWords = {}
    local lineLength = 0

    while lineLength < maxw do
      local word = M.gen_word()
      if lineLength + #word + 1 > maxw then
        break
      end
      table.insert(lineWords, word)
      lineLength = lineLength + #word + 1 -- +1 for the space
    end

    local str = table.concat(lineWords, " ")
    if i < state.linecount then
      str = str .. " "
    end
    table.insert(lines, str)
  end

  return lines
end

M.phrases_to_lines = function()
  local data = state.config.phrases or phrases
  local maxw = state.w_with_pad
  local datalen = #data
  local phrase = data[math.random(1, datalen)]
  local lines = { "" }

  while state.linecount >= #lines do
    for _, v in ipairs(vim.split(phrase, " ")) do
      local arrlen = #lines
      local lastline_len = #lines[arrlen]

      if lastline_len + #v + 2 > maxw then
        local space =  arrlen == state.linecount and "" or " "
        lines[arrlen] = lines[arrlen] .. space
        table.insert(lines, v)
      else
        local space = lastline_len == 0 and "" or " "
        lines[arrlen] = lines[arrlen] .. space .. v
      end
    end

    phrase = data[math.random(1, datalen)]
  end

  return vim.list_slice(lines, 1, state.linecount)
end

-- lines of a snippet that can be typed: tabs expanded, trailing whitespace
-- and blank lines dropped, and nothing wider than the typing area
local snippet_lines = function(snippet)
  local result = {}

  for _, line in ipairs(vim.split(snippet, "\n")) do
    line = line:gsub("\t", "    "):gsub("%s+$", "")

    if line ~= "" and #line <= state.w_with_pad then
      table.insert(result, line)
    end
  end

  return result
end

-- how: for code from files, see code_files.gen_lines
M.code_to_lines = function(how)
  local code = state.config.code
  state.code_source = nil

  if code.paths and #code.paths > 0 then
    local lines, source =
      require("typr.code_files").gen_lines(code.paths, code.filetypes, state.linecount, state.w_with_pad, how)

    if lines then
      state.code_source = source
      return lines
    end

    vim.notify("typr: no code found in " .. table.concat(code.paths, ", ") .. ", using snippets", vim.log.levels.WARN)
  end

  local snippets = (code.snippets or {})[code.lang] or require("typr.constants.code")[code.lang]
  local lines = {}

  -- snippets are taken from their first line so the code reads naturally,
  -- and more are appended until there are enough lines
  for _ = 1, 100 do
    if not snippets or #lines >= state.linecount then
      break
    end

    for _, line in ipairs(snippet_lines(snippets[math.random(1, #snippets)])) do
      if #lines < state.linecount then
        table.insert(lines, line)
      end
    end
  end

  if #lines < state.linecount then
    vim.notify("typr: no code snippets for '" .. tostring(code.lang) .. "'", vim.log.levels.WARN)
    return M.words_to_lines()
  end

  return lines
end

M.mode_funcs = {
  words = M.words_to_lines,
  phrases = M.phrases_to_lines,
  code = M.code_to_lines,
}

-- how: "same", "next" or "jump", for the code mode reading files
M.gen_default_lines = function(how)
  state.default_lines = M.mode_funcs[state.config.mode](how or "same")

  -- one chunk per line keeps the spacing (code indentation) as is
  state.ui_lines = vim.tbl_map(function(line)
    return { { line, "commentfg" } }
  end, state.default_lines)
end

M.gen_lines_diff = function(line, userline)
  local result = {}
  local userlinelen = #userline
  local croppedline = line:sub(1, userlinelen)

  for i = 1, #croppedline do
    local char = line:sub(i, i)
    local expected = userline:sub(i, i)

    local status = char == expected and "Added" or "Removed"

    local resultlen = #result

    if expected ~= char and expected == " " then
      expected = "x"
    end

    if resultlen > 0 and result[resultlen][2] == status then
      result[resultlen][1] = result[resultlen][1] .. expected
    else
      table.insert(result, { expected, status })
    end
  end

  table.insert(result, { line:sub(#userline + 1), "commentfg" })

  return result
end

M.count_correct_words = function()
  local count = 0
  local unmatched_count = 0
  local curchar_count = 0
  local total_char_count = 0
  local userlines = {}

  for _, line in ipairs(state.ui_lines) do
    userlines = vim.list_extend(userlines, line)
  end

  for _, v in ipairs(userlines) do
    local wordslen = #vim.split(v[1], " ")

    if v[2] == "Added" then
      count = count + wordslen
      curchar_count = curchar_count + #v[1]
    elseif v[2] == "Removed" and v[1] ~= " " and v[1] ~= "" then
      unmatched_count = unmatched_count + wordslen
    end

    total_char_count = total_char_count + #v[1]
  end

  local total_words = count + unmatched_count
  state.stats.correct_word_ratio = count .. " / " .. total_words
  state.stats.word_stats = { all = total_words, wrong = unmatched_count }
  state.stats.wpm = math.floor(((curchar_count / 5) / state.secs) * 60)
  state.stats.rawpm = math.floor(((total_char_count / 5) / state.secs) * 60)
end

M.get_accuracy = function()
  local lines = state.ui_lines
  local mystr = ""

  for _, line in ipairs(lines) do
    for _, val in ipairs(line) do
      if val[2] == "Added" then
        mystr = mystr .. val[1]
      end
    end
  end

  local mystrlen = #mystr
  local total_char_count = #table.concat(state.default_lines)
  local accuracy = (mystrlen / total_char_count) * 100

  state.stats.accuracy = math.floor(accuracy)
  state.stats.total_char_count = total_char_count
  state.stats.typed_char_count = mystrlen
end

M.char_accuracy = function()
  local userlines = vim.tbl_map(function(line)
    local userwords = vim.tbl_map(function(v)
      return v[1]
    end, line)

    local userstrs = table.concat(userwords, "")

    return vim.split(userstrs, "")
  end, state.ui_lines)

  local default_lines = vim.tbl_map(function(line)
    return vim.split(line, "")
  end, state.default_lines)

  local wrongchars = {}
  local wrongchars_count = 0
  local totalchars_count = 0
  local rightchars = {}
  local result = {}

  for i, line in ipairs(default_lines) do
    for j, char in ipairs(line) do
      totalchars_count = totalchars_count + 1
      if userlines[i][j] == char then
        rightchars[char] = (rightchars[char] or 0) + 1
      else
        wrongchars[char] = (wrongchars[char] or 0) + 1
        wrongchars_count = wrongchars_count + 1
      end
    end
  end

  state.stats.char_stats = { all = totalchars_count, wrong = wrongchars_count }

  for key, val in pairs(rightchars) do
    local sum = (wrongchars[key] or 0) + val
    result[key] = math.floor((val / sum) * 100)
  end

  state.stats.char_accuracy = result
end

M.char_times_calc = function()
  local t = state.stats.char_times

  local chars = {}
  local pressed = {}

  for _, v in ipairs(t) do
    if v[1] ~= "" and v[1] ~= " " then
      chars[v[1]] = (chars[v[1]] or 0) + v[2]
      pressed[v[1]] = (pressed[v[1]] or 0) + 1
    end
  end

  for k, v in pairs(chars) do
    chars[k] = v / pressed[k]
  end

  state.stats.char_times = chars
end

M.start_timer = function()
  state.timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      state.secs = state.secs + 1
      volt.redraw(state.buf, "stats")
    end)
  )
end

-- typed: text the user has typed so far on each words row (kept on resize)
M.set_emptylines = function(typed)
  local maxline = (state.linecount + state.words_row)
  state.words_row_end = maxline

  local lines = {}
  local pad = string.rep(" ", state.xpad)
  local fill = string.rep(" ", state.xpad + state.w_with_pad)

  for i = 1, state.ypad + state.h do
    local str = fill

    if i > state.words_row and i <= maxline then
      local text = typed and typed[i - state.words_row] or ""
      str = text == "" and "" or pad .. text
    end

    table.insert(lines, str)
  end

  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
end

-- (re)centers the ui in its window and redraws everything
M.relayout = function(keep_typed)
  local api = vim.api
  local buf, win = state.buf, state.win
  local old_xpad, old_ypad = state.xpad, state.ypad
  local typed

  -- with virtualedit the cursor can be past the end of the line, which
  -- nvim_win_get_cursor doesnt report
  local pos = api.nvim_win_call(win, vim.fn.getcurpos)
  local cursor = { pos[2], pos[3] - 1 + pos[4] }

  if keep_typed then
    typed = api.nvim_buf_get_lines(buf, state.words_row, state.words_row + state.linecount, false)

    for i, line in ipairs(typed) do
      typed[i] = line:sub(old_xpad + 1)
    end
  end

  local typr = require "typr"

  -- content height is known only after volt has generated the layout
  state.ypad = 0
  typr.initialize_volt()
  state.h = require("volt.state")[buf].h

  state.xpad, state.ypad = require("typr.win").center(win, state.w_with_pad, state.h)
  state.words_row = state.header_h + state.ypad
  typr.initialize_volt()

  state.relayouting = true
  M.set_emptylines(typed)
  state.relayouting = false

  api.nvim_buf_clear_namespace(buf, state.ns, 0, -1)
  volt.redraw(buf, "all")

  if keep_typed then
    local row = math.min(math.max(cursor[1] + state.ypad - old_ypad, 1), api.nvim_buf_line_count(buf))
    api.nvim_win_set_cursor(win, { row, math.max(cursor[2] + state.xpad - old_xpad, 0) })
  else
    -- the typed text is gone and the words row may have moved (e.g. the
    -- results showing up), so the old cursor spot means nothing anymore
    api.nvim_win_set_cursor(win, { state.words_row + 1, state.xpad })
  end

  require("typr.win").scroll_top(win)
end

M.on_finish = function()
  state.finished = true
  state.timer:stop()
  vim.cmd.stopinsert()

  vim.schedule(function()
    M.get_accuracy()
    M.count_correct_words()
    M.char_accuracy()
    M.char_times_calc()

    M.relayout()

    require("typr.stats.utils").save()
  end)
end

M.handle_test_end = function()
  local pos = vim.api.nvim_win_get_cursor(state.win)
  local curline_endcol = #state.default_lines[pos[1] - state.words_row]
  local cur_col = pos[2] - state.xpad + 1

  if cur_col == curline_endcol then
    if state.words_row_end == pos[1] then
      M.on_finish()
      return
    end

    vim.schedule(function()
      vim.api.nvim_win_set_cursor(state.win, { pos[1] + 1, state.xpad })
    end)
  end
end

return M
