-- Send-to-REPL for interactive evaluation (uses iron's built-in REPL definitions).
return {
    "Vigemus/iron.nvim",
    ft = { "python", "lua", "sh", "bash", "elixir", "javascript", "typescript" },
    config = function()
        local iron = require("iron.core")
        iron.setup({
            config = {
                scratch_repl = true,
                repl_open_cmd = require("iron.view").bottom(15),
            },
            keymaps = {
                toggle_repl = "<leader>ii",
                restart_repl = "<leader>iR",
                send_motion = "<leader>is",
                visual_send = "<leader>is",
                send_line = "<leader>il",
                send_file = "<leader>if",
                exit = "<leader>iq",
                clear = "<leader>ic",
            },
            ignore_blank_lines = true,
        })
    end,
}
