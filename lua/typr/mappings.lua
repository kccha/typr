local state = require "typr.state"
local map = vim.keymap.set
local api = vim.api
local myapi = require "typr.api"

return function()
  map("n", "i", function()
    api.nvim_win_set_cursor(state.win, { state.words_row + 1, state.xpad })
    vim.cmd.startinsert()
  end, { buffer = state.buf })

  map("n", "<C-r>", myapi.restart, { buffer = state.buf })

  map("n", "s", myapi.toggle_symbols, { buffer = state.buf })
  map("n", "n", myapi.toggle_numbers, { buffer = state.buf })
  map("n", "r", myapi.toggle_random, { buffer = state.buf })
  map("n", "p", myapi.toggle_phrases, { buffer = state.buf })

  for _, v in ipairs { 3, 6, 9 } do
    map("n", tostring(v), function()
      myapi.set_linecount(v)
    end, { buffer = state.buf })
  end

  map("n", "o", "", { buffer = state.buf })
  map("i", "<cr>", "", { buffer = state.buf })
  -- a test ends in normal mode, where an <cr> typed out of habit at the end
  -- of the last line would move the cursor down into the padding
  map("n", "<cr>", "", { buffer = state.buf })

  -- deleting past the start of a words line joins it with the line above,
  -- which shifts the padding rows into the words rows
  local at_line_start = function()
    -- with virtualedit the cursor can be past the end of the line, which
    -- nvim_win_get_cursor doesnt report
    local pos = vim.fn.getcurpos()
    return pos[3] - 1 + pos[4] <= state.xpad
  end

  for _, key in ipairs { "<BS>", "<C-h>", "<C-w>", "<C-u>" } do
    map("i", key, function()
      return at_line_start() and "" or key
    end, { buffer = state.buf, expr = true })
  end

  -- deleting forward at the end of a line joins the next one into it
  map("i", "<Del>", "", { buffer = state.buf })

  if state.config.mappings then
    state.config.mappings(state.buf)
  end
end
