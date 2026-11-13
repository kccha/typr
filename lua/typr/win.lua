-- Shows a typr buffer inside the current window (instead of a float) and
-- keeps track of what must be restored once that buffer goes away.
local M = {}
local api = vim.api
local voltstate = require "volt.state"

local winopts = {
  number = false,
  relativenumber = false,
  signcolumn = "no",
  foldcolumn = "0",
  statuscolumn = "",
  cursorline = false,
  cursorcolumn = false,
  colorcolumn = "",
  list = false,
  spell = false,
  foldenable = false,
  wrap = false,
  sidescrolloff = 0,
}

local set_winopts = function(win, opts)
  for name, val in pairs(opts) do
    pcall(function()
      vim.wo[win][0][name] = val
    end)
  end
end

-- usable text area of the window
M.size = function(win)
  local info = vim.fn.getwininfo(win)[1]
  return info.width - info.textoff, info.height
end

-- padding needed to center content of size w x h in the window
M.center = function(win, w, h)
  local winw, winh = M.size(win)
  return math.max(0, math.floor((winw - w) / 2)), math.max(0, math.floor((winh - h) / 2))
end

M.scroll_top = function(win)
  api.nvim_win_call(win, function()
    vim.fn.winrestview { topline = 1, leftcol = 0 }
  end)
end

---@param buf integer
---@param opts { winopts?: table, hl_ns?: integer, on_resize: fun(win: integer), on_close: fun() }
---@return integer win
M.open = function(buf, opts)
  local win = api.nvim_get_current_win()
  local prev_buf = api.nvim_win_get_buf(win)
  local applied = vim.tbl_extend("force", winopts, opts.winopts or {})
  local saved = {}
  local used_wins = { [win] = true }

  for name in pairs(applied) do
    saved[name] = vim.wo[win][0][name]
  end

  vim.bo[buf].bufhidden = "wipe"
  api.nvim_win_set_buf(win, buf)
  set_winopts(win, applied)

  if opts.hl_ns then
    api.nvim_win_set_hl_ns(win, opts.hl_ns)
  end

  -- the buffer can end up in another window (:split, then closing the first
  -- one), so the ui follows the focused window showing it
  local find_win = function()
    local cur = api.nvim_get_current_win()

    if api.nvim_win_get_buf(cur) == buf then
      return cur
    end

    local id = vim.fn.bufwinid(buf)
    return id ~= -1 and id or nil
  end

  local group = api.nvim_create_augroup("Typr" .. buf, {})

  api.nvim_create_autocmd({ "WinResized", "WinEnter", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      local target = find_win()

      if not target then
        return
      end

      local resized = args.event == "WinResized" and vim.tbl_contains(vim.v.event.windows, target)

      if target ~= win or resized then
        win = target
        used_wins[win] = true

        if opts.hl_ns then
          api.nvim_win_set_hl_ns(win, opts.hl_ns)
        end

        opts.on_resize(win)
      end
    end,
  })

  api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      api.nvim_del_augroup_by_id(group)
      voltstate[buf] = nil
      opts.on_close()

      -- the window still has this buffer in it while its being wiped
      vim.schedule(function()
        for id in pairs(used_wins) do
          if api.nvim_win_is_valid(id) then
            set_winopts(id, saved)

            if opts.hl_ns then
              api.nvim_win_set_hl_ns(id, 0)
            end
          end
        end
      end)
    end,
  })

  for _, key in ipairs { "q", "<ESC>" } do
    vim.keymap.set("n", key, function()
      local target = find_win()

      if target then
        if not api.nvim_buf_is_valid(prev_buf) then
          prev_buf = api.nvim_create_buf(true, false)
        end

        api.nvim_win_set_buf(target, prev_buf)
      end

      if api.nvim_buf_is_valid(buf) then
        api.nvim_buf_delete(buf, { force = true })
      end
    end, { buffer = buf })
  end

  return win
end

return M
