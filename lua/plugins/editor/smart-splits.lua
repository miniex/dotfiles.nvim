-- Seamless <C-hjkl> navigation across nvim splits AND tmux/wezterm/kitty/zellij
-- panes (auto-detected). Replaces the old nvim-only directional-memory nav.
local function move(dir)
    return function()
        require("smart-splits")["move_cursor_" .. dir]()
    end
end

return {
    "mrjones2014/smart-splits.nvim",
    keys = {
        { "<C-h>", move("left"), mode = { "n", "t" }, desc = "Move to left pane" },
        { "<C-j>", move("down"), mode = { "n", "t" }, desc = "Move to bottom pane" },
        { "<C-k>", move("up"), mode = { "n", "t" }, desc = "Move to top pane" },
        { "<C-l>", move("right"), mode = { "n", "t" }, desc = "Move to right pane" },
    },
    -- Defaults auto-detect the multiplexer and at_edge per terminal (kitty → stop, else wrap).
    opts = {},
}
