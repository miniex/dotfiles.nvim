return {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
        optional = true,
    },
    keys = {
        {
            "<leader>uw",
            function()
                require("dropbar.api").pick()
            end,
            desc = "Dropbar: pick segment",
        },
        {
            "[w",
            function()
                require("dropbar.api").goto_context_start()
            end,
            desc = "Dropbar: jump to context start",
        },
        {
            "]w",
            function()
                require("dropbar.api").select_next_context()
            end,
            desc = "Dropbar: next context",
        },
    },
    opts = {
        bar = {
            -- Keep the dashboard / neo-tree / terminals clean.
            enable = function(buf, win, _)
                if vim.fn.win_gettype(win) ~= "" then
                    return false
                end
                local bt = vim.bo[buf].buftype
                if bt ~= "" and bt ~= "acwrite" then
                    return false
                end
                local ft = vim.bo[buf].filetype
                if ft == "snacks_dashboard" or ft == "neo-tree" or ft == "Trouble" or ft == "dap-repl" then
                    return false
                end
                if vim.api.nvim_buf_get_name(buf) == "" then
                    return false
                end
                return true
            end,
        },
        icons = {
            ui = {
                bar = {
                    separator = "  ",
                    extends = "…",
                },
            },
        },
    },
    config = function(_, opts)
        require("dropbar").setup(opts)
    end,
}
