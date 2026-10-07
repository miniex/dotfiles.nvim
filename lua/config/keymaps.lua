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
map("<", "<gv", "x", "Outdent (keep selection)")
map(">", ">gv", "x", "Indent (keep selection)")

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
map("J", function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! " .. vim.v.count1 .. "J")
    vim.api.nvim_win_set_cursor(0, pos)
end, "n", "Join lines (keep cursor)")
map("<leader>j", "gJ", "n", "Join lines (no space)")

-- gco / gcO / gcA: not in 0.12's built-in gc. The marker follows the treesitter
-- context (JSX, vue blocks, md fences) the way vim/_comment.lua resolves it.
local function commentstring_at(row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, 0, nil, { error = false })
    if not ok or not parser then
        return vim.bo.commentstring
    end
    parser:parse({ row, row + 1 })
    local caps = vim.treesitter.get_captures_at_pos(0, row, col)
    for i = #caps, 1, -1 do
        local md = caps[i].metadata
        local cs = md["bo.commentstring"] or (md[caps[i].id] and md[caps[i].id]["bo.commentstring"])
        if cs then
            return cs
        end
    end
    -- Deepest language tree at the position with a commentstring.
    local range, found, depth = { row, col, row, col + 1 }, nil, 0
    local function walk(tree, level)
        if not tree:contains(range) then
            return
        end
        for _, ft in ipairs(vim.treesitter.language.get_filetypes(tree:lang())) do
            local cs = vim.filetype.get_option(ft, "commentstring")
            if cs ~= "" and level > depth then
                found, depth = cs, level
            end
        end
        for _, child in pairs(tree:children()) do
            walk(child, level + 1)
        end
    end
    walk(parser, 1)
    return found or vim.bo.commentstring
end

-- One insert: the line is opened / appended by the real o / O / A and the marker
-- typed in, so a single `u` drops the whole comment (API edits + startinsert
-- would split it into two undo steps).
local function comment_insert(where)
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_get_current_line()
    local col = where == "A" and math.max(#line - 1, 0) or (line:find("%S") or 1) - 1
    local cs = commentstring_at(row, col)
    local left, right = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
    left, right = left or "//", right or ""
    local keys = where .. (where == "A" and " " or "") .. left .. " "
    if right ~= "" then
        -- Park before the closer: `{/* | */}`.
        keys = keys .. " " .. right .. ("<C-g>U<Left>"):rep(vim.fn.strchars(right) + 1)
    end
    vim.api.nvim_feedkeys(vim.keycode(keys), "n", false)
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

-- Diagnostics into the native quickfix / loclist (feeds colder/cnewer).
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

-- S-h/l overrides vim's H/L screen jumps; [b/]b are stock 0.11+.
map("<S-h>", "<cmd>bprevious<cr>", "n", "Previous buffer")
map("<S-l>", "<cmd>bnext<cr>", "n", "Next buffer")
