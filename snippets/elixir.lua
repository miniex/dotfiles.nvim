local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("defmod", fmt("defmodule {} do\n  {}\nend", { i(1, "Name"), i(0) })),
    s("def", fmt("def {}({}) do\n  {}\nend", { i(1, "name"), i(2), i(0) })),
    s("defp", fmt("defp {}({}) do\n  {}\nend", { i(1, "name"), i(2), i(0) })),
    s("case", fmt("case {} do\n  {} -> {}\nend", { i(1), i(2, "pattern"), i(0) })),
    s("with", fmt("with {} <- {} do\n  {}\nelse\n  {} -> {}\nend", { i(1, "pattern"), i(2), i(3), i(4, "err"), i(0) })),
    s("test", fmt('test "{}" do\n  {}\nend', { i(1, "description"), i(0) })),
    s("describe", fmt('describe "{}" do\n  {}\nend', { i(1, "context"), i(0) })),
    s(
        "gen",
        fmt(
            [[
defmodule {} do
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(state), do: {{:ok, state}}

  @impl true
  def handle_call({}, _from, state) do
    {{:reply, {}, state}}
  end
end
]],
            { i(1, "Worker"), i(2, ":get"), i(0, "state") }
        )
    ),
    s("iod", fmt('IO.inspect({}, label: "{}")', { i(1), rep(1) })),
}
