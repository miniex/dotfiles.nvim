-- LSP symbol breadcrumb for lualine. Stays visible when winbar (dropbar) is hidden.
return {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
        vim.g.navic_silence = true
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("navic-attach", { clear = true }),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client:supports_method("textDocument/documentSymbol") then
                    require("nvim-navic").attach(client, args.buf)
                end
            end,
        })
    end,
    opts = function()
        return {
            separator = "  ",
            highlight = true,
            depth_limit = 5,
            icons = {
                File = "󰈙 ",
                Module = " ",
                Namespace = "󰌗 ",
                Package = " ",
                Class = "󰌗 ",
                Method = "󰆧 ",
                Property = " ",
                Field = " ",
                Constructor = " ",
                Enum = "󰕘",
                Interface = "󰕘",
                Function = "󰊕 ",
                Variable = "󰆧 ",
                Constant = "󰏿 ",
                String = "󰀬 ",
                Number = "󰎠 ",
                Boolean = "◩ ",
                Array = "󰅪 ",
                Object = "󰅩 ",
                Key = "󰌋 ",
                Null = "󰟢 ",
                EnumMember = " ",
                Struct = "󰌗 ",
                Event = " ",
                Operator = "󰆕 ",
                TypeParameter = "󰊄 ",
            },
            lazy_update_context = true,
        }
    end,
}
