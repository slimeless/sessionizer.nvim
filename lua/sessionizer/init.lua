local utils = require('sessionizer.utils')
local M = {}

local defaults = {
    hide_dot_directories = true,
    debug = false,
    sources = {
        "~/"
    }
}

M.setup = function(opts)
    opts =  opts or {}
    opts = vim.tbl_deep_extend("force", defaults, opts)
    local directories = utils.get_directories(opts.sources, opts.hide_dot_directories)
    vim.api.nvim_create_user_command('Sessionizer', function ()
        utils.create_tmux_picker(require("telescope.themes").get_dropdown{}, directories)
    end, {})
    if opts.debug then
        vim.api.nvim_create_user_command('SessionizerDebug', function ()
            utils.view_sourced_directories(opts.sources, opts.hide_dot_directories)
        end, {})
    end

end
return M
