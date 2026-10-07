return {
    settings = {
        zls = {
            inlay_hints_show_builtin = true,
            inlay_hints_exclude_single_argument = true,
            inlay_hints_hide_redundant_param_names = true,
            inlay_hints_hide_redundant_param_names_last_token = true,
            warn_style = true,
            highlight_global_var_declarations = true,
            force_autofix = false,
            enable_snippets = true,
            enable_argument_placeholders = true,
            -- Off: a full `zig build` per save stalls big projects; AST diagnostics still work.
            enable_build_on_save = false,
            semantic_tokens = "full",
        },
    },
}
