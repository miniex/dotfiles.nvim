-- Task / build runner (make / npm / cargo / go / just / cmake via built-in templates).
return {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerRunCmd", "OverseerInfo", "OverseerQuickAction" },
    keys = {
        { "<leader>Rr", "<cmd>OverseerRun<cr>", desc = "Run task" },
        { "<leader>Rt", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
        { "<leader>Rc", "<cmd>OverseerRunCmd<cr>", desc = "Run shell command" },
        { "<leader>Ra", "<cmd>OverseerQuickAction<cr>", desc = "Task quick action" },
        { "<leader>Ri", "<cmd>OverseerInfo<cr>", desc = "Overseer info" },
    },
    opts = {
        task_list = { direction = "bottom" },
    },
}
