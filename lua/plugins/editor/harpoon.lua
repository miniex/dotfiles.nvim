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
            -- Bracket aliases, matching the config's `[x`/`]x` nav convention.
            {
                "]m",
                function()
                    h():list():next()
                end,
                desc = "Harpoon Next",
            },
            {
                "[m",
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
        -- Fuzzy picker over marks (scales past the 5 numbered slots).
        table.insert(keys, {
            "<leader>mf",
            function()
                local list = h():list()
                local items = {}
                for _, item in ipairs(list.items) do
                    items[#items + 1] = item.value
                end
                require("fzf-lua").fzf_exec(items, {
                    prompt = "Harpoon> ",
                    actions = {
                        ["default"] = function(sel)
                            if sel[1] then
                                vim.cmd.edit(vim.fn.fnameescape(sel[1]))
                            end
                        end,
                    },
                })
            end,
            desc = "Harpoon Pick (fuzzy)",
        })
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
