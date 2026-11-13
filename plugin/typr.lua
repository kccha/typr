vim.api.nvim_create_user_command("Typr", function(args)
  -- :Typr <dir> types code from the files in that directory
  if args.args ~= "" then
    local config = require("typr.state").config
    config.mode = "code"
    config.code.paths = { args.args }
  end

  require("typr").open()
end, { nargs = "?", complete = "dir" })

vim.api.nvim_create_user_command("TyprStats", function()
  require("typr.stats").open()
end, {})
