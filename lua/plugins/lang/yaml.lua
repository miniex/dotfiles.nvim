return {
    require("config.lang").treesitter({ "yaml" }),
    require("config.lang").mason({ "yamllint" }),
    require("config.lang").lint({ yaml = { "yamllint" } }),
}
