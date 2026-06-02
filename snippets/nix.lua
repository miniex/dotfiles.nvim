local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    s("let", fmt("let\n  {} = {};\nin\n{}", { i(1, "name"), i(2, "value"), i(0) })),
    s("rec", fmt("rec {{\n  {} = {};\n  {}\n}}", { i(1, "name"), i(2, "value"), i(0) })),
    s("if", fmt("if {} then {} else {}", { i(1, "cond"), i(2), i(0) })),
    s("with", fmt("with {}; {}", { i(1, "pkgs"), i(0) })),
    s(
        "mkd",
        fmt(
            [[
stdenv.mkDerivation rec {{
  pname = "{}";
  version = "{}";
  src = {};
  buildInputs = [ {} ];
  {}
}}]],
            { i(1, "name"), i(2, "0.1.0"), i(3, "./."), i(4), i(0) }
        )
    ),
    s(
        "flake",
        fmt(
            [[
{{
  description = "{}";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = {{ self, nixpkgs }}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {{ inherit system; }};
  in {{
    {}
  }};
}}]],
            { i(1, "description"), i(0) }
        )
    ),
    s("shell", fmt("pkgs.mkShell {{\n  packages = with pkgs; [ {} ];\n}}", { i(0) })),
}
