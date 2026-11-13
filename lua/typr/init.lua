local M = {}
local api = vim.api
local state = require "typr.state"
local layout = require "typr.ui.layout"
local volt = require "volt"
local utils = require "typr.utils"

M.setup = function(opts)
  state.config = vim.tbl_deep_extend("force", state.config, opts or {})
  require("typr.stats.utils").restore_stats()
end

M.initialize_volt = function()
  volt.gen_data {
    { buf = state.buf, layout = layout, xpad = state.xpad, ns = state.ns },
  }
end

M.open = function()
  if state.buf then
    return
  end

  state.buf = api.nvim_create_buf(false, true)

  state.win = require("typr.win").open(state.buf, {
    winopts = { virtualedit = "all" },
    on_resize = function(win)
      state.win = win
      utils.relayout(true)
    end,
    on_close = function()
      state.reset_vars()
      state.buf = nil
    end,
  })

  utils.gen_default_lines()

  volt.run(state.buf, {
    custom_empty_lines = utils.relayout,
  })

  if state.config.insert_on_start then
    vim.api.nvim_command "startinsert"
  end

  vim.bo[state.buf].filetype = "typr"
  vim.bo[state.buf].ma = true

  api.nvim_win_set_cursor(state.win, { state.words_row + 1, state.xpad })

  local lasttime = 0

  api.nvim_buf_attach(state.buf, false, {
    on_lines = function(_, _, _, line)
      if state.relayouting then
        return
      end

      if not state.lastchar and api.nvim_get_mode().mode == "i" then
        utils.start_timer()
      end

      local curline = api.nvim_get_current_line():sub(state.xpad + 1)
      local words_row = line - state.words_row + 1
      local default_line = state.default_lines[words_row]

      if not default_line then
        return
      end

      state.ui_lines[words_row] = utils.gen_lines_diff(default_line, curline)

      api.nvim_buf_set_extmark(state.buf, state.ns, line, 0, {
        virt_text = state.ui_lines[words_row],
        virt_text_win_col = state.xpad,
        id = line + 1,
      })

      state.lastchar = curline:sub(-1)

      local cur = vim.uv.hrtime()
      table.insert(state.stats.char_times, { state.lastchar, (cur - lasttime) / 1e6 })
      lasttime = cur

      utils.handle_test_end()
    end,
  })

  require "typr.mappings"()

  pcall(function()
    require("cmp").setup.buffer { enabled = false }
  end)

  if type(state.config.on_attach) == "function" then
    state.config.on_attach(state.buf)
  end
end

return M
