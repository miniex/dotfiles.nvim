local diagnostic = vim.diagnostic

diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [diagnostic.severity.ERROR] = "󰅚 ",
            [diagnostic.severity.WARN] = "󰀪 ",
            [diagnostic.severity.HINT] = "󰌶 ",
            [diagnostic.severity.INFO] = "󰋽 ",
        },
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})
