local map = function(lhs, rhs, mode, desc)
    vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = desc })
end

-- Pane navigation (<C-hjkl>) → plugins/editor/smart-splits.nvim (crosses into tmux panes).

-- Treesitter tree viewer (debug captures/queries).
map("<leader>ut", function()
    vim.treesitter.inspect_tree()
end, "n", "Inspect TS tree")

-- zvzz after jumps.
for _, key in ipairs({
    "n",
    "N",
    "*",
    "#",
    "g*",
    "g#",
    "<C-o>",
    "<C-i>",
}) do
    vim.keymap.set("n", key, key .. "zvzz", { silent = true })
end
-- [c/]c are diff-only motions; recenter just in diff mode (they error elsewhere).
for _, key in ipairs({ "[c", "]c" }) do
    vim.keymap.set("n", key, function()
        return vim.wo.diff and key .. "zvzz" or key
    end, { silent = true, expr = true })
end

-- clear search highlight
map("<leader>h", ":nohlsearch<CR>", "n", "Clear search highlight")
map("<Esc>", "<cmd>nohlsearch<cr>", "n", "Clear search highlight")

-- indent
map("<", "<gv", "v", "Outdent (keep selection)")
map(">", ">gv", "v", "Indent (keep selection)")

-- save (in buffer group; <leader>w / delete is adjacent)
map("<leader>bs", ":w<CR>", "n", "Save file")

-- delete without yank (D, not d: <leader>d is dap)
map("<leader>D", '"_d', { "n", "x" }, "Delete (no yank)")

-- normal <leader>P left free for the snacks profiler group
map("<leader>p", function()
    -- Plain paste in indent-sensitive filetypes; `=` would mangle their whitespace.
    local nofmt = { python = true, yaml = true, markdown = true, make = true, sass = true, nim = true, haskell = true }
    vim.cmd(nofmt[vim.bo.filetype] and "normal! p" or "normal! p`[v`]=")
end, "n", "Paste + reindent")
map("<leader>p", '"_dP', "x", "Paste over (no yank)")
map("<leader>P", '"_dP`[v`]=', "x", "Paste over + reindent")

-- join keeping cursor position; gJ (no inserted space) on <leader>j
map("J", "mzJ`z", "n", "Join lines (keep cursor)")
map("<leader>j", "gJ", "n", "Join lines (no space)")

-- gco / gcO / gcA: not in 0.12's built-in gc. The marker is probed with `gcc` on a
-- scratch line, so it follows the treesitter context (JSX, vue blocks, md fences).
local function comment_parts()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, { "\1" })
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    pcall(vim.cmd, "undojoin")
    vim.cmd("normal gcc")
    local probed = vim.api.nvim_get_current_line()
    pcall(vim.cmd, "undojoin")
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    local left, right = probed:match("^%s*(.-)%s*\1%s*(.*)$")
    return left or "//", right or ""
end

local function comment_insert(where)
    local row, line = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_get_current_line()
    local left, right = comment_parts()
    -- `A` rewrites the current line; `o` / `O` open one at the same indent.
    local prefix = (where == "A" and line .. " " or line:match("^%s*")) .. left .. " "
    local at = where == "A" and row - 1 or (where == "O" and row - 1 or row)
    pcall(vim.cmd, "undojoin")
    vim.api.nvim_buf_set_lines(0, at, where == "A" and row or at, false, {
        prefix .. (right ~= "" and " " .. right or ""),
    })
    -- Right-delimited (`{/* */}`) parks before the closer; otherwise append at EOL.
    vim.api.nvim_win_set_cursor(0, { at + 1, right ~= "" and #prefix or 0 })
    vim.cmd(right ~= "" and "startinsert" or "startinsert!")
end

map("gco", function()
    comment_insert("o")
end, "n", "Comment line below")
map("gcO", function()
    comment_insert("O")
end, "n", "Comment line above")
map("gcA", function()
    comment_insert("A")
end, "n", "Comment at end of line")

-- open URL / file under cursor (netrw's gx is disabled)
map("gx", function()
    local cword = vim.fn.expand("<cWORD>")
    local url = cword:match("https?://[%w%-_%.%?:/%+=&#@!~,;'()%%]+")
    if url then
        url = url:gsub("[%.,;:!?'\"%)%]}]+$", "") -- drop trailing sentence / wrap punctuation
    end
    local target = url or vim.fn.expand("<cfile>")
    if target ~= "" then
        vim.ui.open(target)
    end
end, "n", "Open URL/file under cursor")

-- 0.12 built-in undo tree (opt package, needs packadd before first use).
map("<leader>uU", function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("Undotree")
end, "n", "Toggle undotree")

-- 0.12 opt-package command: stub packadds the real :DiffTool on first use, then re-dispatches.
vim.api.nvim_create_user_command("DiffTool", function(o)
    vim.api.nvim_del_user_command("DiffTool")
    vim.cmd("packadd nvim.difftool")
    vim.cmd.DiffTool(o.fargs)
end, { nargs = "*", complete = "file", desc = "Diff two files/dirs (0.12 native)" })

-- require() triggers LuaSnip's lazy load, so this works before any InsertEnter.
map("<leader>fs", function()
    require("luasnip.loaders").edit_snippet_files()
end, "n", "Edit snippets (ft)")

map("<leader>qR", "<cmd>restart<cr>", "n", "Restart Neovim")

-- Quickfix stack history (older/newer lists from :grep, LSP, etc.).
map("<leader>x<", "<cmd>colder<cr>", "n", "Quickfix older")
map("<leader>x>", "<cmd>cnewer<cr>", "n", "Quickfix newer")

-- Diagnostics into the native quickfix / loclist (feeds colder/cnewer + bqf).
map("<leader>xE", vim.diagnostic.setqflist, "n", "Diagnostics → quickfix")
map("<leader>xe", vim.diagnostic.setloclist, "n", "Buffer diagnostics → loclist")

-- Yank file path to `+` — absolute / relative / relative:line variants.
local function yank_path(transform)
    local path = transform()
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "yanked path" })
end
map("<leader>yp", function()
    yank_path(function()
        return vim.fn.expand("%:p")
    end)
end, "n", "Yank file path (absolute)")
map("<leader>yP", function()
    yank_path(function()
        return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
    end)
end, "n", "Yank file path (relative)")
map("<leader>yl", function()
    yank_path(function()
        return vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
    end)
end, "n", "Yank file path:line (relative)")
map("<leader>yg", function()
    require("snacks").gitbrowse({
        what = "permalink",
        open = function(url)
            yank_path(function()
                return url
            end)
        end,
        notify = false,
    })
end, "n", "Yank git permalink (current line)")

-- S-h/l overrides vim's H/L screen jumps; [b/]b come from mini.bracketed.
map("<S-h>", "<cmd>bprevious<cr>", "n", "Previous buffer")
map("<S-l>", "<cmd>bnext<cr>", "n", "Next buffer")
