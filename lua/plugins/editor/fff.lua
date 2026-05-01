return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    keys = {
        {
            "<leader>ff",
            function()
                require("fff").find_files()
            end,
            desc = "Find Files (fff)",
        },
        {
            "<leader>fF",
            function()
                require("fff").find_files_in_dir(vim.fn.expand("%:p:h"))
            end,
            desc = "Find Files in current directory (fff)",
        },
    },
    opts = {
        prompt = "  ",
        ui = {
            wrap_paths = true,
            path_position = "tail",
        },
    },
}
