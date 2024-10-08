local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"

local M = {}

local function open_tmux_session(selected, selected_name, tmux_running)
    if vim.fn.empty(vim.env.TMUX) == 1 and vim.fn.empty(tmux_running) == 1 then
        os.execute('tmux new-session -s ' .. selected_name .. ' -c ' .. selected)
        os.execute('tmux neww -n "neovim" -t ' .. selected_name .. ' -c ' .. selected .. ' nvim .')
    else
        local session_exists = vim.fn.system('tmux has-session -t=' .. selected_name .. ' 2>/dev/null')
        if vim.fn.empty(session_exists) then
            os.execute('tmux new-session -ds ' .. selected_name .. ' -c ' .. selected)
        end
        os.execute('tmux switch-client -t ' .. selected_name)
    end
end

local function create_dir_table(directories)
    local dir_list = {}
    for _, dir in ipairs(directories) do
        -- Expand the directory path
        local expanded_dir = vim.fn.expand(dir)
        -- Check if the directory exists
        if vim.fn.isdirectory(expanded_dir) == 1 then
            table.insert(dir_list, expanded_dir)
        end
    end
    return dir_list
end


M.create_tmux_picker = function(opts, directories)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select a Directory",
        finder = finders.new_table {
            results = create_dir_table(directories),
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                if selection then
                    local selected = selection.value
                    local selected_name = vim.fn.fnamemodify(selected, ':t'):gsub('%.', '_')
                    local tmux_running = vim.fn.system('pgrep tmux')
                    open_tmux_session(selected, selected_name, tmux_running)

                end
            end)
            return true
        end,
    }):find()
end

return M

