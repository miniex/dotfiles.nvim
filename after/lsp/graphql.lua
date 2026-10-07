-- The bundled root_dir calls on_dir(nil) when no config is found, which still
-- attaches to every tsx/jsx buffer. GraphQL projects only.
return {
    root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, function(name)
            return name:match("^%.graphqlrc") or name:match("^%.?graphql%.config%.") or name == ".graphqlconfig"
        end)
        if root then
            on_dir(root)
        end
    end,
}
