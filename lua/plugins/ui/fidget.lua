-- LSP progress only; snacks.notifier owns vim.notify (fidget's
-- override_vim_notify defaults off, so its notification window is unused).
return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
        progress = {
            display = {
                done_icon = "✓",
                progress_icon = { pattern = "dots", period = 1 },
            },
        },
    },
}
