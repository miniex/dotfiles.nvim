-- Cached catppuccin "mocha" palette; statusline + plugins share one parse.
-- M.blue / M.pink are the two damin brand accents (single source of truth).
local M = {
    blue = "#98ABCC", -- cool
    pink = "#E890B0", -- warm
    mid = "#C09DBE", -- blue→pink gradient midpoint (dashboard header)
    dim = "#6E7A95", -- muted accent
    -- Git accents (shared by themes + statusline).
    git_add = "#A8DBB6", -- mint
    git_delete = "#D8788C", -- rose
    indent = "#6a5260", -- snacks indent guide
}

function M.mocha()
    if not M._cache then
        M._cache = require("catppuccin.palettes").get_palette("mocha")
    end
    return M._cache
end

return M
