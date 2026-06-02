return {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    capabilities = {
        offsetEncoding = { "utf-16" },
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
    -- Priority-grouped (0.11+): each nested table is one tier, outer order is
    -- priority. Build system beats compile DB beats .git.
    root_markers = {
        {
            ".clangd",
            "CMakeLists.txt",
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja",
            "xmake.lua",
        },
        {
            "compile_commands.json",
            "compile_flags.txt",
        },
        ".git",
    },
}
