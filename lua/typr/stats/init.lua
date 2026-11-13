local M = {}
local api = vim.api
local state = require "typr.state"
local volt = require "volt"
local utils = require "typr.stats.utils"

M.open = function()
  if state.statsbuf then
    return
  end

  state.statsbuf = api.nvim_create_buf(false, true)

  state.statswin = require("typr.win").open(state.statsbuf, {
    hl_ns = state.ns,
    on_resize = function(win)
      state.statswin = win
      utils.relayout()
    end,
    on_close = function()
      state.statsbuf = nil
    end,
  })

  require "volt.highlights"
  require "typr.ui.hl"(state.ns, "stats")

  volt.run(state.statsbuf, { custom_empty_lines = utils.relayout })

  vim.keymap.set("n", "<tab>", function()
    state.months_toggled = not state.months_toggled
    volt.redraw(state.statsbuf, "typrStats")
  end, { buffer = state.statsbuf })

  vim.keymap.set("n", "D", function()
    state.tab = "  Dashboard"
    volt.redraw(state.statsbuf, "all")
  end, { buffer = state.statsbuf })

  vim.keymap.set("n", "K", function()
    state.tab = "Keystrokes"
    volt.redraw(state.statsbuf, "all")
  end, { buffer = state.statsbuf })

  vim.keymap.set("n", "H", function()
    state.tab = "  History"
    volt.redraw(state.statsbuf, "all")
  end, { buffer = state.statsbuf })

  vim.keymap.set("n", "<C-t>", function()
    state.horiz_i = state.horiz_i == 3 and 1 or state.horiz_i + 1
    volt.redraw(state.statsbuf, "all")
  end, { buffer = state.statsbuf })

  vim.bo[state.statsbuf].filetype = "typrstats"
end

return M
