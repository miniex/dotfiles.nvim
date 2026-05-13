-- Surround pairs. `gs*` prefix (flash.nvim owns `s`).
return {
    "echasnovski/mini.surround",
    keys = function(_, keys)
        local opts =
            require("lazy.core.plugin").values(require("lazy.core.config").spec.plugins["mini.surround"], "opts", false)
        local mappings = {
            { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
            { opts.mappings.delete, desc = "Delete surrounding" },
            { opts.mappings.find, desc = "Find right surrounding" },
            { opts.mappings.find_left, desc = "Find left surrounding" },
            { opts.mappings.highlight, desc = "Highlight surrounding" },
            { opts.mappings.replace, desc = "Replace surrounding" },
            { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
        }
        return vim.list_extend(mappings, keys)
    end,
    opts = {
        mappings = {
            add = "gsa",
            delete = "gsd",
            find = "gsf",
            find_left = "gsF",
            highlight = "gsh",
            replace = "gsr",
            update_n_lines = "gsn",
            suffix_last = "l",
            suffix_next = "n",
        },
        n_lines = 50,
        search_method = "cover_or_next",
        silent = true,
    },
}
