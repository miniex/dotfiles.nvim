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

-- Treesitter attach (registered here so it fires for files opened during
-- startup, before nvim-treesitter plugin loads). vim.treesitter is a builtin;
-- only the parser .so on rtp is required.
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("ts-attach", { clear = true }),
    callback = function(args)
        if not vim.treesitter.highlighter.active[args.buf] then
            local ft = vim.bo[args.buf].filetype
            if not ft or ft == "" then
                return
            end
            local lang = vim.treesitter.language.get_lang(ft) or ft
            if not lang or lang == "" then
                return
            end
            if not pcall(vim.treesitter.start, args.buf, lang) then
                return
            end
        end
        -- Override default filetype indent (BufWinEnter runs after it).
        if package.loaded["nvim-treesitter"] then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
