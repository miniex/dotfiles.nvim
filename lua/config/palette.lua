-- Cached catppuccin "mocha" palette; lualine + incline share one parse.
local M = {}

function M.mocha()
    if not M._cache then
        M._cache = require("catppuccin.palettes").get_palette("mocha")
    end
    return M._cache
end

return M
