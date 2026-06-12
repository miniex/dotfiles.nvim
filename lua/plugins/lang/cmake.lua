return {
    {
        "Civitasv/cmake-tools.nvim",
        lazy = true,
        init = function()
            local loaded = false
            local function check()
                local cwd = vim.uv.cwd()
                if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
                    require("lazy").load({ plugins = { "cmake-tools.nvim" } })
                    loaded = true
                end
            end
            -- Defer so launching in a CMake project doesn't force-load mid-startup.
            vim.schedule(check)
            vim.api.nvim_create_autocmd("DirChanged", {
                group = vim.api.nvim_create_augroup("CmakeToolsLazyLoad", { clear = true }),
                callback = function()
                    if not loaded then
                        check()
                    end
                    -- true deletes the autocmd, so post-load DirChanged stops stat-ing CMakeLists.txt.
                    return loaded
                end,
            })
        end,
        opts = {},
    },
}
