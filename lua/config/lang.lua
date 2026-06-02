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

return M
