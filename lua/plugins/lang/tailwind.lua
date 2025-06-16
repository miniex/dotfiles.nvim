return {
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_exclude = { "markdown" },
          filetypes_include = {},
          settings = {
            tailwindCSS = {
              includeLanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },
            },
          },
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          local lspconfig = require("lspconfig")
          local tw = lspconfig.tailwindcss.default_config
          opts.filetypes = opts.filetypes or {}

          vim.list_extend(opts.filetypes, tw.filetypes)

          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, opts.filetypes)

          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
      },
    },
  },
}