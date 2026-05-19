return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    keys = {
        {
            "<leader>ff",
            function()
                require("fff").find_files()
            end,
            desc = "Find Files (fff)",
        },
        {
            "<leader>fF",
            function()
                require("fff").find_files_in_dir(vim.fn.expand("%:p:h"))
            end,
            desc = "Find Files in current directory (fff)",
        },
    },
    opts = {
        prompt = "  ",
        title = "✿ files ✿",
        layout = {
            -- snacks.picker has input on top → match.
            prompt_position = "top",
            preview_position = "right",
            preview_size = 0.5,
        },
        ui = {
            wrap_paths = true,
            path_position = "tail",
        },
        hl = { title = "FloatTitle" },
    },
    config = function(_, opts)
        require("fff").setup(opts)
        local ok, picker_ui = pcall(require, "fff.picker_ui")
        if not ok then
            return
        end

        -- Replace picker_ui's file-local BORDER_PRESETS with flower corners.
        -- It only honors preset names, so vim.o.winborder = "✿,…" gets ignored.
        local visited = {}
        local function walk(fn, patch)
            if type(fn) ~= "function" or visited[fn] then
                return
            end
            visited[fn] = true
            local i = 1
            while true do
                local name, val = debug.getupvalue(fn, i)
                if not name then
                    return
                end
                patch(fn, i, name, val)
                if type(val) == "function" then
                    walk(val, patch)
                end
                i = i + 1
            end
        end
        for _, v in pairs(picker_ui) do
            walk(v, function(fn, i, name, val)
                if name == "BORDER_PRESETS" and type(val) == "table" then
                    local new = {}
                    for k in pairs(val) do
                        new[k] = vim.g.flower_border
                    end
                    debug.setupvalue(fn, i, new)
                end
            end)
        end

        -- fff sets titles from BOTH nvim_open_win and nvim_win_set_config (the
        -- preview's file path updates dynamically) — wrap both, decorate, center.
        local function is_fff_caller()
            for level = 2, 6 do
                local info = debug.getinfo(level, "S")
                if not info then
                    return false
                end
                if info.source and info.source:match("fff[/.\\]") then
                    return true
                end
            end
            return false
        end

        local function decorate(config)
            if type(config) ~= "table" or type(config.title) ~= "string" then
                return
            end
            local trimmed = config.title:gsub("^%s+", ""):gsub("%s+$", "")
            if trimmed:find("✿") then
                config.title_pos = "center"
                return
            end
            config.title = " ✿ " .. trimmed .. " ✿ "
            config.title_pos = "center"
        end

        local orig_open = vim.api.nvim_open_win
        vim.api.nvim_open_win = function(buf, enter, config)
            if is_fff_caller() then
                decorate(config)
            end
            return orig_open(buf, enter, config)
        end

        local orig_set_config = vim.api.nvim_win_set_config
        vim.api.nvim_win_set_config = function(win, config)
            if is_fff_caller() then
                decorate(config)
            end
            return orig_set_config(win, config)
        end
    end,
}
