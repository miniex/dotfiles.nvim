-- Auto reload file when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    command = "checktime",
})

-- WSL2 clipboard sync via clip.exe
local clip = "/mnt/c/Windows/System32/clip.exe"
if vim.fn.executable(clip) == 1 then
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("WSLYank", { clear = true }),
        callback = function()
            local content = table.concat(vim.v.event.regcontents, "\n")
            vim.system({ clip }, { stdin = content })
        end,
    })
end

-- Treesitter attach. Registered before plugins so it fires for files opened
-- during startup. vim.treesitter is a builtin; only the parser .so on rtp is
-- required. Canonical pattern: resolve lang via get_lang (handles ft/parser
-- naming mismatches like typescriptreact -> tsx), skip if no parser maps.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ts-attach", { clear = true }),
    callback = function(args)
        if vim.treesitter.highlighter.active[args.buf] then
            return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
            return
        end
        if not pcall(vim.treesitter.start, args.buf) then
            return
        end
        -- Defer indentexpr so we override the default ftplugin indent.
        vim.schedule(function()
            if package.loaded["nvim-treesitter"] and vim.api.nvim_buf_is_valid(args.buf) then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end)
    end,
})
