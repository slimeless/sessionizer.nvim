local utils = require('sessionizer.utils')
local M = {}

local defaults = {
    sources = {
        "~/Documents"
    }
}

M.setup = function(opts)
    opts =  opts or {}
    opts = vim.tbl_deep_extend("force", defaults, opts)
    vim.api.nvim_create_user_command('OpenTmuxSession', function ()
        utils.create_tmux_picker(require("telescope.themes").get_dropdown{}, opts.sources)
    end, {})

end
return M
