local M = {}
local state = require "typr.state"
local voltui = require "volt.ui"

M.ypad = function()
  local lines = {}

  for _ = 1, state.ypad do
    table.insert(lines, {})
  end

  return lines
end

M.words = function()
  return state.ui_lines
end

M.headerbtns = function()
  local config = state.config

  local line = {
    { "  Symbols ", config.symbols and "exgreen" or "normal" },
    { "   Numbers ", config.numbers and "exgreen" or "normal" },
    { "   Random ", config.random and "exgreen" or "normal" },
    { "   Phrases ", config.mode == 'phrases' and "exgreen" or "normal" },
    { "   Code ", config.mode == "code" and "exgreen" or "normal" },
    { "_pad_" },
    -- just the current count, all of them dont fit; changed with 1-0
    { "Lines ", "exred" },
    { string.format("%2d", state.linecount) },
  }

  -- 4 = border charw+pad 2 and 2 on both sides
  local lines = { voltui.hpad(line, state.w_with_pad - 4) }
  voltui.border(lines)
  return lines
end

M.stats = function()
  local stats = state.stats

  if state.secs == 0 then
    -- where the code being typed comes from, when its from files
    local source = state.code_source and state.config.mode == "code" and state.code_source

    if source and #source > state.w_with_pad then
      source = "…" .. source:sub(-(state.w_with_pad - 1))
    end

    return { source and { { source, "commentfg" } } or {}, {} }
  end

  if stats.rawpm == 0 then
    return {
      { { string.rep(" ", (state.w_with_pad / 2) - 3) }, { "  " .. state.secs .. "s  " } },
    }
  end

  local txts = {
    { "Results:", "Added" },
    { "  Words : " .. stats.correct_word_ratio },
    { "    Accuracy: " .. stats.accuracy .. "%" },
    { "_pad_" },
    { "    " .. state.secs .. "s  " },
    { " WPM ", "pmenusel" },
    { " " .. stats.wpm .. " ", "visual" },
  }

  local totalstrlen = 0

  for _, v in ipairs(txts) do
    totalstrlen = totalstrlen + vim.api.nvim_strwidth(v[1])
  end

  local lines = { voltui.hpad(txts, state.w_with_pad - 4) }
  voltui.border(lines)
  table.insert(lines, {})
  return lines
end

M.mappings = function()
  return {
    {
      { " ESC ", "visual" },
      { " or ", "commentfg" },
      { " q ", "visual" },
      { " - Quit ", "commentfg" },

      { "  " },

      { " i ", "visual" },
      { " - Start ", "commentfg" },

      { "  " },

      { " 1-0 ", "visual" },
      { " - Lines ", "commentfg" },

      { "  " },

      { " CTRL ", "visual" },
      { " " },
      { " R ", "visual" },
      { " - Restart ", "commentfg" },
    },
  }
end

return M
