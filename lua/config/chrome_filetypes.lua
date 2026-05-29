-- "Not a real editable file" filetypes, shared by scrollbar / smear-cursor /
-- modicator / incline. Use M.set() to build a lookup from the lists below.
local M = {}

-- Floating picker overlays (snacks / fff / fzf).
M.pickers = {
    "snacks_picker_input",
    "snacks_picker_list",
    "snacks_picker_preview",
    "snacks_terminal",
    "fff_input",
    "fff_list",
    "fff_preview",
    "fzf",
    "fzflua_backdrop",
}

-- Docked / popup panels and special buffers.
M.panels = {
    "snacks_dashboard",
    "neo-tree",
    "neo-tree-popup",
    "Trouble",
    "trouble",
    "dap-repl",
    "dapui_console",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "aerial",
    "lazy",
    "mason",
    "harpoon",
    "qf",
    "nvim-undotree",
}

-- Build a { [ft] = true } lookup from one or more of the lists above.
function M.set(...)
    local out = {}
    for _, list in ipairs({ ... }) do
        for _, ft in ipairs(list) do
            out[ft] = true
        end
    end
    return out
end

return M
