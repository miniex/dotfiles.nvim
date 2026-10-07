return {
    require("config.lang").treesitter({ "hcl", "terraform" }),
    require("config.lang").mason({ "tflint" }),
    require("config.lang").lint({ terraform = { "tflint" } }),
}
