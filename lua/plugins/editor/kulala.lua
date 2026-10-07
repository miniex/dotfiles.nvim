-- In-editor REST/HTTP client for `.http` / `.rest` files (env, GraphQL).
return {
    "mistweaverco/kulala.nvim",
    ft = { "http" },
    -- .http is stock; .rest isn't.
    init = function()
        vim.filetype.add({ extension = { rest = "http" } })
    end,
    opts = {},
    keys = {
        {
            "<leader>kr",
            function()
                require("kulala").run()
            end,
            desc = "REST: run request",
        },
        {
            "<leader>ka",
            function()
                require("kulala").run_all()
            end,
            desc = "REST: run all",
        },
        {
            "<leader>kp",
            function()
                require("kulala").replay()
            end,
            desc = "REST: replay last",
        },
        {
            "<leader>ki",
            function()
                require("kulala").inspect()
            end,
            desc = "REST: inspect",
        },
        {
            "<leader>kc",
            function()
                require("kulala").copy()
            end,
            desc = "REST: copy as curl",
        },
    },
}
