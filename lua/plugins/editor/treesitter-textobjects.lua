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

        local function map_move(lhs, capture, dir, side, desc)
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
                _ = side
            end, { desc = desc })
        end

        map_move("]f", "@function.outer", "next", nil, "Next function start")
        map_move("[f", "@function.outer", "prev", nil, "Prev function start")
        map_move("]F", "@function.outer", "next_end", nil, "Next function end")
        map_move("[F", "@function.outer", "prev_end", nil, "Prev function end")
        map_move("]c", "@class.outer", "next", nil, "Next class start")
        map_move("[c", "@class.outer", "prev", nil, "Prev class start")
    end,
}
