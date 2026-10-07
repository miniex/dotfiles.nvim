-- Send-to-REPL for interactive evaluation (uses iron's built-in REPL definitions).
return {
    "Vigemus/iron.nvim",
    -- Loaded on first REPL key; iron's setup() then owns these maps and lazy replays the key.
    cmd = { "IronRepl", "IronRestart", "IronFocus", "IronHide" },
    keys = {
        { "<leader>ii", desc = "REPL toggle" },
        { "<leader>iR", desc = "REPL restart" },
        { "<leader>is", mode = { "n", "x" }, desc = "REPL send" },
        { "<leader>il", desc = "REPL send line" },
        { "<leader>if", desc = "REPL send file" },
        { "<leader>iq", desc = "REPL exit" },
        { "<leader>ic", desc = "REPL clear" },
    },
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
        })
    end,
}
