return {
    require("config.lang").treesitter({ "nix" }),
    require("config.lang").mason({ "statix" }),
    require("config.lang").lint({ nix = { "statix" } }),
}
