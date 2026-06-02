-- Grammars (terraform, hcl) live in the base treesitter list.
return {
    require("config.lang").mason({ "tflint" }),
    require("config.lang").lint({ terraform = { "tflint" } }),
}
