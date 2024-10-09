local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"

local M = {}

local function is_dot_directory(path)
    local dir_name = vim.fn.fnamemodify(path, ':t')  -- Get the name of the directory
    return dir_name:sub(1, 1) == '.'
end

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


M.get_directories = function(directories, hide_dot_directories)
    local dir_list = {}
    for _, dir in ipairs(directories) do
        local expanded_dir = vim.fn.expand(dir)
        if vim.fn.isdirectory(expanded_dir) == 1 then
            for local_dir in vim.fs.dir(expanded_dir) do
                local expanded_local_dir = vim.fn.expand(local_dir)
                local path = vim.fs.joinpath(expanded_dir, expanded_local_dir)
                if vim.fn.isdirectory(path) == 1 then
                    if hide_dot_directories then
                        if not is_dot_directory(path) then
                            table.insert(dir_list, path)
                        end
                    else
                        table.insert(dir_list, path)
                    end
                end
            end
        end
    end
    return dir_list
end


M.create_tmux_picker = function(opts, directories)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select a Directory",
        finder = finders.new_table {
            results = directories,
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
local function add_prefix(list, hide_dot_directories)
    for i=1, #list do
        if hide_dot_directories then
            if not is_dot_directory(list[i]) then
                list[i] = 'DIR: ' .. list[i] .. ' ..loaded!'
            else
                list[i] = 'DIR: ' .. list[i] .. ' ..disabled!'
            end
        else
            list[i] = 'DIR: ' .. list[i] .. ' ..loaded!'
        end
    end
    return list
end

M.view_sourced_directories = function(directories, hide_dot_directories)
    directories = M.get_directories(directories, false)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd('vsplit')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, add_prefix(directories, hide_dot_directories))
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_set_current_buf(buf)
    vim.fn.matchadd('Identifier', 'DIR: ', 10)
    vim.fn.matchadd('Comment', '..loaded!', 10)
    vim.fn.matchadd('Error', '..disabled!', 10)

end

return M

