-- Spec-fragment helpers for lang/* files. Each returns a lazy plugin spec for
-- the common single-purpose shapes (mason tools, treesitter parsers, blink
-- sources, nvim-lint linters). Specs with extra keys stay inline.
local M = {}

-- mason-tool-installer ensure_installed. Table-form relies on lsp/init.lua's
-- `opts_extend = { "ensure_installed" }`, so the list APPENDS to the global one.
function M.mason(tools)
    return {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { ensure_installed = tools },
    }
end

-- treesitter ensure_installed extend + optional language.register(s).
-- `register` maps a base parser to a filetype/list, e.g. { markdown = "mdx" }.
function M.treesitter(parsers, register)
    return {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            if parsers then
                vim.list_extend(opts.ensure_installed, parsers)
            end
            if register then
                for base, ft in pairs(register) do
                    vim.treesitter.language.register(base, ft)
                end
            end
        end,
    }
end

-- blink.cmp sources fragment: per_filetype + providers, never `default`
-- (setting default clobbers the global). Optional spec, no-op if blink absent.
function M.blink(per_filetype, providers)
    return {
        "saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                per_filetype = per_filetype,
                providers = providers,
            },
        },
    }
end

-- nvim-lint linters_by_ft merge. `by_ft` is a { ft = { "linter" } } map.
function M.lint(by_ft)
    return {
        "mfussenegger/nvim-lint",
        opts = function(_, opts)
            opts.linters_by_ft = opts.linters_by_ft or {}
            for ft, linters in pairs(by_ft) do
                opts.linters_by_ft[ft] = linters
            end
        end,
    }
end

-- Code-action-only runner for a single LSP kind (e.g. "source.organizeImports").
function M.code_action_only(kind)
    return function()
        vim.lsp.buf.code_action({
            context = { only = { kind }, diagnostics = {} },
            apply = true,
        })
    end
end

-- `<leader>c<letter>` code-action keys, buffer-local per `ft`. Letter `o` (not
-- `I`): `<leader>cI` is the global Incoming Calls map and would shadow it.
local CODE_ACTIONS = {
    o = { kind = "source.organizeImports", desc = "Organize Imports" },
    X = { kind = "source.fixAll", desc = "Fix All" },
    U = { kind = "source.removeUnused", desc = "Remove Unused" },
}
-- Buffer-local, not lazy `keys`: there `ft` only gates loading, so the LHS would
-- leak globally (wrong desc in every buffer). FileType maps confine it to `ft`.
function M.code_action_keys(label, letters, ft)
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("code-action-keys-" .. label, { clear = true }),
        pattern = ft,
        callback = function(args)
            for _, letter in ipairs(letters) do
                local a = CODE_ACTIONS[letter]
                if a then -- skip a letter not in CODE_ACTIONS rather than erroring per-FileType
                    vim.keymap.set("n", "<leader>c" .. letter, M.code_action_only(a.kind), {
                        buffer = args.buf,
                        desc = label .. ": " .. a.desc,
                    })
                end
            end
        end,
    })
    return { "neovim/nvim-lspconfig" }
end

return M
