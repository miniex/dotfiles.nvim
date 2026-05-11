return {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
        {
            "<leader>bd",
            function()
                local bd = require("mini.bufremove").delete
                if vim.bo.modified then
                    local choice =
                        vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
                    if choice == 1 then
                        vim.cmd.write()
                        bd(0)
                    elseif choice == 2 then
                        bd(0, true)
                    end
                else
                    bd(0)
                end
            end,
            desc = "Delete Buffer (preserve layout)",
        },
        {
            "<leader>bD",
            function()
                require("mini.bufremove").delete(0, true)
            end,
            desc = "Delete Buffer (force)",
        },
    },
}
