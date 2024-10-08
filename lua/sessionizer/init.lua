local utils = require('sessionizer.utils')
local M = {}

local defaults = {
    directories = {
        "~"
    }
}

M.setup = function(opts)
    opts = opts or defaults
    vim.api.nvim_create_user_command('OpenTmuxSession', function ()
        utils.create_tmux_picker(require("telescope.themes").get_dropdown{}, opts.directories)
    end, {})

end
return M
