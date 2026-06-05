-- `:checkhealth dotfiles` — live in-editor port of tools/health.sh (enabled langs → Mason servers).
local M = {}

local h = vim.health

local function exe(cmd)
    return vim.fn.executable(cmd) == 1
end

local function ver(cmd)
    return (vim.fn.system({ cmd, "--version" }):gsub("\n.*", ""))
end

function M.check()
    h.start("Neovim")
    if vim.fn.has("nvim-0.12") == 1 then
        h.ok("nvim " .. tostring(vim.version()))
    else
        h.warn("config targets nvim >= 0.12")
    end

    h.start("Required tools")
    for _, t in ipairs({ "git", "rg" }) do
        if exe(t) then
            h.ok(t)
        else
            h.error(t .. " not on PATH")
        end
    end
    if exe("cc") or exe("gcc") or exe("clang") then
        h.ok("C compiler (treesitter / native builds)")
    else
        h.error("no C compiler (cc / gcc / clang)")
    end
    if exe("tree-sitter") then
        local v = ver("tree-sitter"):match("%d+%.%d+%.%d+")
        if v and pcall(vim.version.ge, v, "0.26.1") and vim.version.ge(v, "0.26.1") then
            h.ok("tree-sitter " .. v)
        else
            h.warn("tree-sitter " .. (v or "?") .. " — need >= 0.26.1 (cargo/distro, not npm)")
        end
    else
        h.warn("tree-sitter CLI not on PATH (cargo or distro, NOT npm)")
    end

    h.start("Enabled languages → Mason LSP servers")
    local ok_l, langs = pcall(require, "config.langs")
    local ok_m, map = pcall(require, "config.lang_servers")
    if not (ok_l and ok_m) then
        h.error("could not load config.langs / config.lang_servers")
    else
        local installed = {}
        local ok_mlsp, mlsp = pcall(require, "mason-lspconfig")
        if ok_mlsp then
            for _, s in ipairs(mlsp.get_installed_servers()) do
                installed[s] = true
            end
        end
        local enabled, want, seen = {}, {}, {}
        for lang, on in pairs(langs) do
            if on then
                enabled[#enabled + 1] = lang
                for _, s in ipairs(map[lang] or {}) do
                    if not seen[s] then
                        seen[s] = true
                        want[#want + 1] = s
                    end
                end
            end
        end
        -- typos_lsp is language-agnostic — appended unconditionally in lsp/init.lua.
        if not seen["typos_lsp"] then
            want[#want + 1] = "typos_lsp"
        end
        table.sort(enabled)
        table.sort(want)
        h.info("enabled: " .. table.concat(enabled, ", "))
        if next(installed) == nil then
            -- Empty in a cold session = mason-lspconfig not loaded yet, not "none installed".
            h.warn(
                "mason-lspconfig reports nothing installed — likely not loaded yet (open :Mason or re-run after startup)"
            )
        else
            local missing = 0
            for _, s in ipairs(want) do
                if installed[s] then
                    h.ok(s)
                else
                    missing = missing + 1
                    h.warn(s .. " not installed — :LspInstall " .. s)
                end
            end
            if missing == 0 then
                h.ok("all enabled-lang servers installed")
            end
        end
    end

    h.start("Toolchains")
    local function lang_on(name)
        return select(2, pcall(require, "config.langs"))[name] == true
    end
    if exe("node") then
        h.ok("node " .. ver("node"))
    else
        h.warn("node missing — npm-based Mason packages won't install")
    end
    if lang_on("go") then
        if exe("go") then
            h.ok("go")
        else
            h.warn("go missing — gopls / delve affected")
        end
    end
    if lang_on("python") then
        if exe("python3") then
            h.ok("python3")
        else
            h.warn("python3 missing — debugpy affected")
        end
    end
    -- cargo unconditional: fff.nvim's build needs it regardless of rust.
    if exe("cargo") then
        h.ok("cargo")
    else
        h.warn("cargo missing — rustaceanvim / fff.nvim build affected")
    end

    h.start("Clipboard bridge (yank → system)")
    local bridge
    for _, c in ipairs({ "wl-copy", "xclip", "pbcopy", "clip.exe" }) do
        if exe(c) then
            h.ok(c)
            bridge = true
            break
        end
    end
    if not bridge then
        h.warn("no clipboard tool (wl-copy / xclip / pbcopy / clip.exe) — OSC52 fallback only")
    end

    h.start("Optional")
    for _, t in ipairs({ "lazygit", "fzf", "just", "magick" }) do
        if exe(t) then
            h.ok(t)
        else
            h.warn(t .. " missing")
        end
    end
end

return M
