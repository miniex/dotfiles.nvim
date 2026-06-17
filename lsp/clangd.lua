-- Cap background-index workers at half the cores so the first index doesn't peg the CPU.
local jobs = math.max(2, math.floor((vim.uv.available_parallelism and vim.uv.available_parallelism() or 4) / 2))

return {
    cmd = {
        "clangd",
        "--background-index",
        "-j=" .. jobs,
        "--pch-storage=memory",
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
        -- Placeholders come from the --function-arg-placeholders flag above, not here.
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
