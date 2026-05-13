-- Nerd Font v3.4 PUA glyphs via \u{}. md-* needs SupplementaryPUA fallback in kitty.conf.
local g = {
    -- Languages (md-language_* — proper brand logos)
    rust = "\u{f1617}", -- md-language_rust (the crab)
    python = "\u{f0320}", -- md-language_python
    js = "\u{f031e}", -- md-language_javascript
    ts = "\u{f06e6}", -- md-language_typescript
    c = "\u{f0671}", -- md-language_c
    cpp = "\u{f0672}", -- md-language_cpp
    go = "\u{f07d3}", -- md-language_go
    java = "\u{f0b37}", -- md-language_java
    ruby = "\u{f0d2d}", -- md-language_ruby
    lua = "\u{f08b1}", -- md-language_lua
    swift = "\u{f06e5}", -- md-language_swift
    kotlin = "\u{f1219}", -- md-language_kotlin
    php = "\u{f031f}", -- md-language_php
    html = "\u{f031d}", -- md-language_html5
    css = "\u{f031c}", -- md-language_css3
    markdown = "\u{f0354}", -- md-language_markdown

    -- Frameworks / runtimes (md-* where available, seti-* fallback)
    react = "\u{f0708}", -- md-react
    vue = "\u{f0844}", -- md-vuejs
    nodejs = "\u{f0399}", -- md-nodejs
    npm = "\u{f06f7}", -- md-npm
    yarn = "\u{e8ec}", -- seti-yarn (md doesn't have it)
    pnpm = "\u{e865}", -- seti-pnpm
    bun = "\u{e76f}", -- seti-bun
    deno = "\u{e7c0}", -- seti-deno
    svelte = "\u{e6a1}", -- seti-svelte
    astro = "\u{e735}", -- seti-astro
    angular = "\u{e753}", -- dev-angular (legacy pos, still in font)
    babel = "\u{e75d}", -- seti-babel
    rollup = "\u{e892}", -- seti-rollup
    eslint = "\u{e7d2}", -- seti-eslint
    prettier = "\u{e6b4}", -- seti-prettier
    tailwind = "\u{f13ff}", -- md-tailwind
    firebase = "\u{f0967}", -- md-firebase
    graphql = "\u{f0877}", -- md-graphql

    -- Platforms / tools
    docker = "\u{f0868}", -- md-docker
    git = "\u{f02a2}", -- md-git
    github = "\u{f02a4}", -- md-github
    gitlab = "\u{f0ba0}", -- md-gitlab
    apple = "\u{f302}", -- linux-apple (font-logos)
    android = "\u{f17b}", -- fa-android

    -- Generic / file glyphs
    crate = "\u{f03d7}", -- md-package_variant_closed (Rust crate)
    package = "\u{f03d6}", -- md-package_variant
    cube = "\u{f01a6}", -- md-cube
    pallet = "\u{f184e}", -- md-shipping_pallet
    file = "\u{f0214}", -- md-file
    document = "\u{f0219}", -- md-file_document
    folder = "\u{f024b}", -- md-folder
    cog = "\u{f0493}", -- md-cog
    cogout = "\u{f08bb}", -- md-cog_outline
    leaf = "\u{f032a}", -- md-leaf
    rocket = "\u{f14de}", -- md-rocket_launch
    history = "\u{f02da}", -- md-history
    book = "\u{f00ba}", -- md-book
    bookopen = "\u{f00bd}", -- md-book_open
    bookmark = "\u{f00c0}", -- md-bookmark
    check = "\u{f0791}", -- md-check_decagram
    checkcirc = "\u{f05e0}", -- md-check_circle
    flask = "\u{f0093}", -- md-flask
    testtube = "\u{f0668}", -- md-test_tube
    bug = "\u{f00e4}", -- md-bug
    broom = "\u{f00e2}", -- md-broom
    tag = "\u{f04f9}", -- md-tag
    group = "\u{f0849}", -- md-account_group
    cloud = "\u{f015f}", -- md-cloud
    database = "\u{f01bc}", -- md-database
    key = "\u{f0306}", -- md-key
    keyvar = "\u{f030b}", -- md-key_variant
    shield = "\u{f0498}", -- md-shield
    shieldlock = "\u{f099d}", -- md-shield_lock
    lock = "\u{f023}", -- fa-lock (compact, fits well next to filename)
    brain = "\u{f09d1}", -- md-brain
    head = "\u{f1344}", -- md-head_lightbulb
    robot = "\u{f06a9}", -- md-robot
    robothappy = "\u{f171a}", -- md-robot_happy_outline
    pickaxe = "\u{f08b7}", -- md-pickaxe
    magic = "\u{f0d0}", -- fa-magic
    chip = "\u{f2db}", -- fa-microchip
    json = "\u{eb0f}", -- seti-json
    yaml = "\u{e8eb}", -- seti-yml
}

return {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
        color_icons = true,
        default = true,
        strict = false,

        override_by_filename = {
            -- Rust  (crate icon for the manifest, lock for lockfile, crab for rust configs)
            ["Cargo.toml"] = { icon = g.crate, color = "#dea584", name = "CargoToml" },
            ["Cargo.lock"] = { icon = g.lock, color = "#dea584", name = "CargoLock" },
            ["rust-toolchain"] = { icon = g.rust, color = "#dea584", name = "RustToolchain" },
            ["rust-toolchain.toml"] = { icon = g.rust, color = "#dea584", name = "RustToolchainToml" },
            ["clippy.toml"] = { icon = g.rust, color = "#dea584", name = "ClippyToml" },
            ["rustfmt.toml"] = { icon = g.rust, color = "#dea584", name = "RustfmtToml" },

            -- Python
            ["pyproject.toml"] = { icon = g.python, color = "#ffbc03", name = "PyProject" },
            ["poetry.lock"] = { icon = g.lock, color = "#ffbc03", name = "PoetryLock" },
            ["uv.lock"] = { icon = g.lock, color = "#de5fe9", name = "UvLock" },
            ["Pipfile"] = { icon = g.python, color = "#3572a5", name = "Pipfile" },
            ["Pipfile.lock"] = { icon = g.lock, color = "#3572a5", name = "PipfileLock" },
            ["ruff.toml"] = { icon = g.broom, color = "#d7ba7d", name = "RuffToml" },
            ["conftest.py"] = { icon = g.testtube, color = "#ffbc03", name = "Conftest" },
            ["tox.ini"] = { icon = g.testtube, color = "#ffbc03", name = "ToxIni" },
            ["setup.py"] = { icon = g.python, color = "#ffbc03", name = "SetupPy" },
            ["setup.cfg"] = { icon = g.cog, color = "#ffbc03", name = "SetupCfg" },
            ["requirements.txt"] = { icon = g.python, color = "#ffbc03", name = "Requirements" },

            -- JS / TS modern tooling
            ["biome.json"] = { icon = g.cog, color = "#60a5fa", name = "BiomeJson" },
            ["biome.jsonc"] = { icon = g.cog, color = "#60a5fa", name = "BiomeJsonc" },
            ["deno.json"] = { icon = g.deno, color = "#84cc16", name = "DenoJson" },
            ["deno.jsonc"] = { icon = g.deno, color = "#84cc16", name = "DenoJsonc" },
            ["deno.lock"] = { icon = g.lock, color = "#84cc16", name = "DenoLock" },
            ["turbo.json"] = { icon = g.rocket, color = "#ef4444", name = "TurboJson" },
            ["nx.json"] = { icon = g.cog, color = "#96d0e2", name = "NxJson" },
            ["lerna.json"] = { icon = g.cog, color = "#9333ea", name = "LernaJson" },
            ["bunfig.toml"] = { icon = g.bun, color = "#fbf0df", name = "Bunfig" },
            ["jsr.json"] = { icon = g.cube, color = "#facc15", name = "JsrJson" },
            ["jsr.jsonc"] = { icon = g.cube, color = "#facc15", name = "JsrJsonc" },
            [".node-version"] = { icon = g.nodejs, color = "#8cc84b", name = "NodeVersion" },
            [".tool-versions"] = { icon = g.cogout, color = "#42a5f5", name = "ToolVersions" },

            -- Frameworks (web-devicons covers vite/next/nuxt/svelte/tailwind/eslint/prettier configs)
            ["astro.config.mjs"] = { icon = g.astro, color = "#ff5d01", name = "AstroConfigMjs" },
            ["astro.config.cjs"] = { icon = g.astro, color = "#ff5d01", name = "AstroConfigCjs" },
            ["astro.config.js"] = { icon = g.astro, color = "#ff5d01", name = "AstroConfigJs" },
            ["astro.config.ts"] = { icon = g.astro, color = "#ff5d01", name = "AstroConfigTs" },
            ["svelte.config.cjs"] = { icon = g.svelte, color = "#ff3e00", name = "SvelteConfigCjs" },
            ["svelte.config.mjs"] = { icon = g.svelte, color = "#ff3e00", name = "SvelteConfigMjs" },
            ["svelte.config.ts"] = { icon = g.svelte, color = "#ff3e00", name = "SvelteConfigTs" },
            ["remix.config.js"] = { icon = g.react, color = "#0ea5e9", name = "RemixConfigJs" },
            ["remix.config.ts"] = { icon = g.react, color = "#0ea5e9", name = "RemixConfigTs" },
            ["angular.json"] = { icon = g.angular, color = "#dd0531", name = "AngularJson" },
            ["nest-cli.json"] = { icon = g.cog, color = "#e0234e", name = "NestCli" },
            ["app.json"] = { icon = g.react, color = "#61dafb", name = "AppJson" },
            ["app.config.js"] = { icon = g.react, color = "#61dafb", name = "AppConfigJs" },
            ["app.config.ts"] = { icon = g.react, color = "#61dafb", name = "AppConfigTs" },
            ["expo.json"] = { icon = g.react, color = "#000020", name = "ExpoJson" },
            ["metro.config.js"] = { icon = g.cog, color = "#ef4444", name = "MetroConfig" },
            ["babel.config.js"] = { icon = g.babel, color = "#cbcb41", name = "BabelConfigJs" },
            ["babel.config.json"] = { icon = g.babel, color = "#cbcb41", name = "BabelConfigJson" },
            ["babel.config.ts"] = { icon = g.babel, color = "#cbcb41", name = "BabelConfigTs" },
            ["postcss.config.js"] = { icon = g.css, color = "#dd3a0a", name = "PostcssConfigJs" },
            ["postcss.config.cjs"] = { icon = g.css, color = "#dd3a0a", name = "PostcssConfigCjs" },
            ["postcss.config.mjs"] = { icon = g.css, color = "#dd3a0a", name = "PostcssConfigMjs" },
            ["postcss.config.ts"] = { icon = g.css, color = "#dd3a0a", name = "PostcssConfigTs" },
            ["rollup.config.js"] = { icon = g.rollup, color = "#ef3335", name = "RollupConfigJs" },
            ["rollup.config.ts"] = { icon = g.rollup, color = "#ef3335", name = "RollupConfigTs" },
            ["esbuild.config.js"] = { icon = g.rocket, color = "#ffcf00", name = "EsbuildConfigJs" },
            ["esbuild.config.mjs"] = { icon = g.rocket, color = "#ffcf00", name = "EsbuildConfigMjs" },

            -- Env files
            [".env.local"] = { icon = g.leaf, color = "#faf743", name = "EnvLocal" },
            [".env.development"] = { icon = g.leaf, color = "#faf743", name = "EnvDev" },
            [".env.development.local"] = { icon = g.leaf, color = "#faf743", name = "EnvDevLocal" },
            [".env.production"] = { icon = g.leaf, color = "#faf743", name = "EnvProd" },
            [".env.production.local"] = { icon = g.leaf, color = "#faf743", name = "EnvProdLocal" },
            [".env.staging"] = { icon = g.leaf, color = "#faf743", name = "EnvStaging" },
            [".env.test"] = { icon = g.leaf, color = "#faf743", name = "EnvTest" },
            [".env.example"] = { icon = g.leaf, color = "#faf743", name = "EnvExample" },
            [".env.sample"] = { icon = g.leaf, color = "#faf743", name = "EnvSample" },
            [".env.template"] = { icon = g.leaf, color = "#faf743", name = "EnvTemplate" },

            -- C / C++
            ["CMakePresets.json"] = { icon = g.cog, color = "#6d8086", name = "CMakePresets" },
            ["CMakeUserPresets.json"] = { icon = g.cog, color = "#6d8086", name = "CMakeUserPresets" },
            ["meson.build"] = { icon = g.cog, color = "#a52e62", name = "MesonBuild" },
            ["meson_options.txt"] = { icon = g.cog, color = "#a52e62", name = "MesonOptions" },
            ["conanfile.txt"] = { icon = g.cube, color = "#5b6a72", name = "Conanfile" },
            ["conanfile.py"] = { icon = g.cube, color = "#5b6a72", name = "ConanfilePy" },
            ["vcpkg.json"] = { icon = g.cube, color = "#0078d4", name = "VcpkgJson" },

            -- Mobile
            ["Podfile"] = { icon = g.apple, color = "#e91e63", name = "Podfile" },
            ["Podfile.lock"] = { icon = g.lock, color = "#e91e63", name = "PodfileLock" },
            ["pubspec.yaml"] = { icon = g.cube, color = "#54c5f8", name = "Pubspec" },
            ["pubspec.yml"] = { icon = g.cube, color = "#54c5f8", name = "PubspecYml" },
            ["pubspec.lock"] = { icon = g.lock, color = "#54c5f8", name = "PubspecLock" },
            ["Info.plist"] = { icon = g.apple, color = "#0099ff", name = "InfoPlist" },
            ["AndroidManifest.xml"] = { icon = g.android, color = "#34a853", name = "AndroidManifest" },

            -- Docs / meta
            ["README"] = { icon = g.bookopen, color = "#42a5f5", name = "Readme" },
            ["LICENSE"] = { icon = g.shield, color = "#d0bf41", name = "License" },
            ["LICENSE.txt"] = { icon = g.shield, color = "#d0bf41", name = "LicenseTxt" },
            ["LICENSE.md"] = { icon = g.shield, color = "#d0bf41", name = "LicenseMd" },
            ["COPYING"] = { icon = g.shield, color = "#d0bf41", name = "Copying" },
            ["AUTHORS.md"] = { icon = g.group, color = "#a172ff", name = "AuthorsMd" },
            ["CONTRIBUTING.md"] = { icon = g.bookopen, color = "#42a5f5", name = "Contributing" },
            ["CHANGELOG.md"] = { icon = g.history, color = "#7eb0d2", name = "Changelog" },
            ["TODO"] = { icon = g.checkcirc, color = "#7eb0d2", name = "Todo" },
            ["TODO.md"] = { icon = g.checkcirc, color = "#7eb0d2", name = "TodoMd" },
            ["NOTES.md"] = { icon = g.bookmark, color = "#7eb0d2", name = "NotesMd" },

            -- AI / Agents
            ["CLAUDE.md"] = { icon = g.brain, color = "#cc785c", name = "Claude" },
            ["AGENTS.md"] = { icon = g.robothappy, color = "#10a37f", name = "AgentsMd" },
            [".cursorrules"] = { icon = g.magic, color = "#22d3ee", name = "Cursorrules" },
            [".aider.conf.yml"] = { icon = g.robot, color = "#a855f7", name = "AiderConf" },

            -- CI / deploy / tooling
            ["renovate.json"] = { icon = g.cog, color = "#1f8eed", name = "Renovate" },
            ["renovate.json5"] = { icon = g.cog, color = "#1f8eed", name = "Renovate5" },
            ["dependabot.yml"] = { icon = g.cog, color = "#0366d6", name = "Dependabot" },
            ["Brewfile"] = { icon = g.cube, color = "#701516", name = "Brewfile" },
            ["Procfile"] = { icon = g.cog, color = "#a074c4", name = "Procfile" },
            ["fly.toml"] = { icon = g.cloud, color = "#7b3aed", name = "FlyToml" },
            ["railway.toml"] = { icon = g.cloud, color = "#9333ea", name = "RailwayToml" },
            ["wrangler.toml"] = { icon = g.cloud, color = "#f48120", name = "WranglerToml" },
            ["Earthfile"] = { icon = g.pallet, color = "#9354c5", name = "Earthfile" },
            ["Justfile"] = { icon = g.rocket, color = "#42a5f5", name = "Justfile" },
            ["justfile"] = { icon = g.rocket, color = "#42a5f5", name = "JustfileLower" },
            ["Taskfile.yml"] = { icon = g.check, color = "#5fbcec", name = "Taskfile" },
            ["Taskfile.yaml"] = { icon = g.check, color = "#5fbcec", name = "TaskfileYaml" },

            -- Editor / VCS
            ["lazy-lock.json"] = { icon = g.lock, color = "#51a0cf", name = "LazyLock" },
            ["lazyvim.json"] = { icon = g.cog, color = "#51a0cf", name = "LazyVim" },
        },

        override_by_extension = {
            mdx = { icon = g.markdown, color = "#519aba", name = "Mdx" },
            mts = { icon = g.ts, color = "#519aba", name = "Mts" },
            cts = { icon = g.ts, color = "#519aba", name = "Cts" },
            mjs = { icon = g.js, color = "#cbcb41", name = "Mjs" },
            cjs = { icon = g.js, color = "#cbcb41", name = "Cjs" },
            pyi = { icon = g.python, color = "#ffbc03", name = "Pyi" },
            lock = { icon = g.lock, color = "#bbbbbb", name = "Lock" },
            jsonl = { icon = g.json, color = "#cbcb41", name = "Jsonl" },
            ndjson = { icon = g.json, color = "#cbcb41", name = "Ndjson" },
            parquet = { icon = g.database, color = "#50c878", name = "Parquet" },
            wgsl = { icon = g.chip, color = "#005a9c", name = "Wgsl" },
            hlsl = { icon = g.chip, color = "#005a9c", name = "Hlsl" },
            metal = { icon = g.chip, color = "#a020f0", name = "Metal" },
            prompt = { icon = g.brain, color = "#10a37f", name = "Prompt" },
        },
    },
}
