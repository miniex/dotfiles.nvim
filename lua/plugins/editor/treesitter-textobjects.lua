return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        select = {
            lookahead = true,
        },
    },
    config = function(_, opts)
        require("nvim-treesitter-textobjects").setup(opts)

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")
        local ts_repeat = require("nvim-treesitter-textobjects.repeatable_move")

        local function map_select(lhs, capture, desc)
            vim.keymap.set({ "x", "o" }, lhs, function()
                select.select_textobject(capture, "textobjects")
            end, { desc = desc })
        end

        map_select("af", "@function.outer", "Function (outer)")
        map_select("if", "@function.inner", "Function (inner)")
        map_select("ac", "@class.outer", "Class (outer)")
        map_select("ic", "@class.inner", "Class (inner)")
        map_select("aa", "@parameter.outer", "Parameter (outer)")
        map_select("ia", "@parameter.inner", "Parameter (inner)")
        map_select("ai", "@conditional.outer", "Conditional (outer)")
        map_select("ii", "@conditional.inner", "Conditional (inner)")
        map_select("al", "@loop.outer", "Loop (outer)")
        map_select("il", "@loop.inner", "Loop (inner)")
        map_select("a/", "@comment.outer", "Comment (outer)")
        map_select("i/", "@comment.inner", "Comment (inner)")
        map_select("a=", "@assignment.outer", "Assignment (outer)")
        map_select("i=", "@assignment.inner", "Assignment (inner)")
        map_select("am", "@call.outer", "Call (outer)")
        map_select("im", "@call.inner", "Call (inner)")
        -- B/S use capitals because lowercase b is vim's word-back motion and
        -- s is owned by flash; these stay free for textobject use.
        map_select("aB", "@block.outer", "Block (outer)")
        map_select("iB", "@block.inner", "Block (inner)")
        map_select("aS", "@statement.outer", "Statement (outer)")

        local function map_move(lhs, capture, dir, desc)
            vim.keymap.set({ "n", "x", "o" }, lhs, function()
                if dir == "next" then
                    move.goto_next_start(capture, "textobjects")
                elseif dir == "prev" then
                    move.goto_previous_start(capture, "textobjects")
                elseif dir == "next_end" then
                    move.goto_next_end(capture, "textobjects")
                elseif dir == "prev_end" then
                    move.goto_previous_end(capture, "textobjects")
                end
            end, { desc = desc })
        end

        map_move("]f", "@function.outer", "next", "Next function start")
        map_move("[f", "@function.outer", "prev", "Prev function start")
        map_move("]F", "@function.outer", "next_end", "Next function end")
        map_move("[F", "@function.outer", "prev_end", "Prev function end")
        -- Capital C to keep `]c`/`[c` (next/prev change in diff mode) free.
        map_move("]C", "@class.outer", "next", "Next class start")
        map_move("[C", "@class.outer", "prev", "Prev class start")
        map_move("]a", "@parameter.inner", "next", "Next parameter")
        map_move("[a", "@parameter.inner", "prev", "Prev parameter")

        -- Swap parameter with next / prev — useful when reordering arguments.
        vim.keymap.set("n", "<leader>cA", function()
            swap.swap_next("@parameter.inner", "textobjects")
        end, { desc = "Swap parameter with next" })
        vim.keymap.set("n", "<leader>cS", function()
            swap.swap_previous("@parameter.inner", "textobjects")
        end, { desc = "Swap parameter with prev" })

        -- Reorder sibling functions/methods (j = down/next, k = up/prev).
        vim.keymap.set("n", "<leader>cj", function()
            swap.swap_next("@function.outer", "textobjects")
        end, { desc = "Swap function with next" })
        vim.keymap.set("n", "<leader>ck", function()
            swap.swap_previous("@function.outer", "textobjects")
        end, { desc = "Swap function with prev" })

        -- `;`/`,` repeat the last move; goto_* are auto-wrapped by the move module,
        -- with builtin f/t/F/T fallback (their expr maps record themselves).
        -- flash char mode is disabled (flash.lua) to cede f/t/;/, here.
        vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next, { desc = "Repeat last move (next)" })
        vim.keymap.set(
            { "n", "x", "o" },
            ",",
            ts_repeat.repeat_last_move_previous,
            { desc = "Repeat last move (prev)" }
        )
        vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat.builtin_f_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat.builtin_F_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat.builtin_t_expr, { expr = true })
        vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat.builtin_T_expr, { expr = true })
    end,
}
