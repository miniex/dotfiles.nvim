return {
    "zeioth/garbage-day.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    event = "LspAttach",
    opts = {
        aggressive_mode = false,
        excluded_lsp_clients = {
            "null-ls",
            "jdtls",
            "rust_analyzer",
        },
        grace_period = 60 * 15,
        wakeup_delay = 3000,
        notifications = false,
        retries = 3,
        timeout = 1000,
    },
}
