-- yazi (Rust TUI file manager). Needs the `yazi` binary installed
-- (`cargo install --locked yazi-fm yazi-cli` or a system package); `:checkhealth yazi`.
return {
    "mikavilpas/yazi.nvim",
    version = "*",
    cmd = "Yazi",
    keys = {
        { "<leader>-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Yazi (current file)" },
        { "<leader>fy", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { open_for_directories = false },
}
