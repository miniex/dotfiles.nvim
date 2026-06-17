-- ;/, repeat the last todo jump (ts-textobjects' repeatable_move). require is
-- deferred into the callback so the spec doesn't load ts-textobjects at startup.
local function todo_move(opts)
    if opts.forward then
        require("todo-comments").jump_next()
    else
        require("todo-comments").jump_prev()
    end
end
local function todo_jump(forward)
    return function()
        local ok, rm = pcall(require, "nvim-treesitter-textobjects.repeatable_move")
        if ok then
            rm.make_repeatable_move(todo_move)({ forward = forward })
        else
            todo_move({ forward = forward })
        end
    end
end

return {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TodoTrouble" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
        { "]t", todo_jump(true), desc = "Next Todo Comment" },
        { "[t", todo_jump(false), desc = "Previous Todo Comment" },
        { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
        { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
        {
            "<leader>ft",
            function()
                Snacks.picker.todo_comments()
            end,
            desc = "Todo (Picker)",
        },
    },
}
