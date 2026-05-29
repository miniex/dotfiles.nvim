-- Cached catppuccin "mocha" palette; lualine + incline share one parse.
-- M.blue / M.pink are the two damin brand accents (single source of truth).
local M = {
    blue = "#98ABCC", -- cool
    pink = "#E890B0", -- warm
    -- Git accents (shared by themes + scrollbar marks).
    git_add = "#A8DBB6", -- mint
    git_delete = "#D8788C", -- rose
}

function M.mocha()
    if not M._cache then
        M._cache = require("catppuccin.palettes").get_palette("mocha")
    end
    return M._cache
end

return M
