-- VSCode-style code action indicator in the sign column.
-- damin tone: pink ❋ glyph, hooked to LspAttach.
return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        -- Driven by our own guarded CursorHold autocmd (config) — the plugin's autocmd
        -- has no big-file guard. enabled=false also leaves the global updatetime alone.
        autocmd = { enabled = false },
        sign = {
            enabled = true,
            text = "❋",
            hl = "LightBulbSign",
        },
        virtual_text = { enabled = false },
        float = { enabled = false },
        status_text = { enabled = false },
        number = { enabled = false },
        line = { enabled = false },
    },
    config = function(_, opts)
        require("nvim-lightbulb").setup(opts)

        -- Shares init.lua's per-buffer cache key, so the size stat is paid once per buffer.
        local function buf_is_big(buf)
            local cached = vim.b[buf]._lsp_buf_is_big
            if cached ~= nil then
                return cached
            end
            local name = vim.api.nvim_buf_get_name(buf)
            local big = name ~= "" and vim.fn.getfsize(name) > 1 * 1024 * 1024
            if not big then
                local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
                big = first ~= nil and #first > 2000
            end
            vim.b[buf]._lsp_buf_is_big = big
            return big
        end

        -- Buffer-local CursorHold per LSP attach, so non-LSP buffers skip the
        -- codeAction scan. No CursorHoldI: no requests on insert idle.
        local grp = vim.api.nvim_create_augroup("LightBulbGuarded", { clear = true })
        vim.api.nvim_create_autocmd("LspAttach", {
            group = grp,
            callback = function(args)
                local buf = args.buf
                if vim.b[buf]._lightbulb_done then
                    return
                end
                vim.b[buf]._lightbulb_done = true
                vim.api.nvim_create_autocmd("CursorHold", {
                    buffer = buf,
                    group = grp,
                    callback = function()
                        if not buf_is_big(buf) then
                            require("nvim-lightbulb").update_lightbulb()
                        end
                    end,
                })
            end,
        })

        local function set_hl()
            vim.api.nvim_set_hl(0, "LightBulbSign", { fg = require("config.palette").pink, bg = "NONE" })
        end
        set_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("LightBulbDamin", { clear = true }),
            callback = set_hl,
        })
    end,
}
