-- Seamless <C-hjkl> navigation across nvim splits AND tmux/wezterm/kitty/zellij
-- panes (auto-detected). Replaces the old nvim-only directional-memory nav.
local function move(dir)
    return function()
        require("smart-splits")["move_cursor_" .. dir]()
    end
end

return {
    "smart-splits-nvim/smart-splits.nvim",
    -- Normal mode only: in terminals the shell / lazygit own <C-l> (clear), <C-k> (kill-line).
    keys = {
        { "<C-h>", move("left"), desc = "Move to left pane" },
        { "<C-j>", move("down"), desc = "Move to bottom pane" },
        { "<C-k>", move("up"), desc = "Move to top pane" },
        { "<C-l>", move("right"), desc = "Move to right pane" },
    },
    -- Defaults auto-detect the multiplexer and at_edge per terminal (kitty → stop, else wrap).
    opts = {},
}
