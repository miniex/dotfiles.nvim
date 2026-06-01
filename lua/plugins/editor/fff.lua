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
        -- 0.85 × 0.85, input top, preview right 50% — matches snacks.picker.
        layout = {
            width = 0.85,
            height = 0.85,
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
        local ok, layout = pcall(require, "fff.layout")
        if not ok then
            return
        end

        -- Replace layout.lua's file-local BORDER_PRESETS with flower corners (fff
        -- only honors preset *names*, so vim.o.winborder = "✿,…" is ignored).
        local patched = false
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
        for _, v in pairs(layout) do
            walk(v, function(fn, i, name, val)
                if name == "BORDER_PRESETS" and type(val) == "table" then
                    local new = {}
                    for k in pairs(val) do
                        new[k] = vim.g.flower_border
                    end
                    debug.setupvalue(fn, i, new)
                    patched = true
                end
            end)
        end
        if not patched then
            vim.schedule(function()
                vim.notify("fff: BORDER_PRESETS upvalue missing — border patch skipped", vim.log.levels.WARN)
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

        -- Skip the stack walk for floats without a title — most of them.
        local function decorate_if_fff(_, config)
            if type(config) ~= "table" or type(config.title) ~= "string" then
                return
            end
            if is_fff_caller() then
                decorate(config)
            end
        end
        require("config.modal-floats").add_decorator("fff_title", {
            open = decorate_if_fff,
            set_config = decorate_if_fff,
        })
    end,
}
