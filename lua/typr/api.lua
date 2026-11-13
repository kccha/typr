local M = {}
local volt = require "volt"
local state = require "typr.state"
local utils = require "typr.utils"

M.redraw_words_header = function(mode)
  state.config.mode = mode or "words"
  volt.redraw(state.buf, "headerbtns")
  utils.gen_default_lines()
  volt.redraw(state.buf, { "words", "stats" })
end

M.toggle_symbols = function()
  state.config.symbols = not state.config.symbols
  M.redraw_words_header()
end

M.toggle_numbers = function()
  state.config.numbers = not state.config.numbers
  M.redraw_words_header()
end

M.toggle_random = function()
  state.config.random = not state.config.random
  M.redraw_words_header()
end

-- switches between words and the given mode (phrases or code)
local toggle_mode = function(mode)
  state.config.mode = state.config.mode == mode and "words" or mode

  -- these only apply to the words mode
  if state.config.mode ~= "words" then
    state.config.numbers = false
    state.config.symbols = false
    state.config.random = false
  end

  M.redraw_words_header(state.config.mode)
end

M.toggle_phrases = function()
  toggle_mode "phrases"
end

M.toggle_code = function()
  toggle_mode "code"
end

M.set_linecount = function(x)
  state.linecount = x
  utils.gen_default_lines()
  utils.relayout()
end

-- code read from files carries on from where a finished test stopped, while
-- a test restarted midway is typed again
M.restart = function()
  local how = state.finished and "next" or "same"
  state.reset_vars()
  utils.gen_default_lines(how)
  utils.relayout()
end

-- code from files: start reading somewhere else
M.jump = function()
  state.reset_vars()
  utils.gen_default_lines "jump"
  utils.relayout()
end

return M
