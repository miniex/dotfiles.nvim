return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
        local h = function()
            return require("harpoon")
        end
        local keys = {
            {
                "<leader>ma",
                function()
                    h():list():add()
                end,
                desc = "Harpoon Add",
            },
            {
                "<leader>mm",
                function()
                    -- Geometry is snapped by modal-geom's FileType aligner.
                    h().ui:toggle_quick_menu(h():list(), {
                        border = vim.g.flower_border,
                        title = " ✿ harpoon ✿ ",
                        title_pos = "center",
                    })
                end,
                desc = "Harpoon Menu",
            },
            {
                "<leader>md",
                function()
                    h():list():remove()
                end,
                desc = "Harpoon Remove",
            },
            {
                "<leader>mn",
                function()
                    h():list():next()
                end,
                desc = "Harpoon Next",
            },
            {
                "<leader>mp",
                function()
                    h():list():prev()
                end,
                desc = "Harpoon Prev",
            },
        }
        for i = 1, 5 do
            table.insert(keys, {
                "<leader>m" .. i,
                function()
                    h():list():select(i)
                end,
                desc = "Harpoon Slot " .. i,
            })
        end
        return keys
    end,
    config = function()
        require("harpoon"):setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        })
    end,
}
