-- Grammars (terraform, hcl) live in the base treesitter list.
return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { ensure_installed = { "tflint" } },
    },
    {
        "mfussenegger/nvim-lint",
        opts = function(_, opts)
            opts.linters_by_ft = opts.linters_by_ft or {}
            opts.linters_by_ft.terraform = { "tflint" }
        end,
    },
}
