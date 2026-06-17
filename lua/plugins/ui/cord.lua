return {
    "vyfor/cord.nvim",
    -- cord auto-starts a Discord-IPC daemon on load (no setup() needed); pointless in headless/SSH.
    cond = function()
        return #vim.api.nvim_list_uis() > 0 and not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION)
    end,
    event = "VeryLazy",
    build = ":Cord update",
}
