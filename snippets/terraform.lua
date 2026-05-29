local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("res", fmt('resource "{}" "{}" {{\n  {}\n}}', { i(1, "type"), i(2, "name"), i(0) })),
    s("data", fmt('data "{}" "{}" {{\n  {}\n}}', { i(1, "type"), i(2, "name"), i(0) })),
    s(
        "var",
        fmt(
            'variable "{}" {{\n  type        = {}\n  description = "{}"\n  default     = {}\n}}',
            { i(1, "name"), i(2, "string"), i(3, "description"), i(0, "null") }
        )
    ),
    s("out", fmt('output "{}" {{\n  value = {}\n}}', { i(1, "name"), i(0, "value") })),
    s("mod", fmt('module "{}" {{\n  source = "{}"\n  {}\n}}', { i(1, "name"), i(2, "./module"), i(0) })),
    s("prov", fmt('provider "{}" {{\n  {}\n}}', { i(1, "name"), i(0) })),
    s("locals", fmt("locals {{\n  {}\n}}", { i(0) })),
    s(
        "tf",
        fmt(
            'terraform {{\n  required_providers {{\n    {} = {{\n      source  = "{}"\n      version = "{}"\n    }}\n  }}\n}}',
            { i(1, "aws"), i(2, "hashicorp/aws"), i(0, "~> 5.0") }
        )
    ),
    s("backend", fmt('terraform {{\n  backend "{}" {{\n    {}\n  }}\n}}', { i(1, "s3"), i(0) })),
}
