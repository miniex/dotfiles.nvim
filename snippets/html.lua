local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    -- HTML5 boilerplate
    s(
        "html5",
        fmt(
            [[<!DOCTYPE html>
<html lang="{}">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{}</title>
</head>
<body>
    {}
</body>
</html>]],
            { i(1, "en"), i(2, "Document"), i(0) }
        )
    ),
    s("img", fmt('<img src="{}" alt="{}" />', { i(1, "src"), i(2, "alt") })),
    s("link", fmt('<link rel="stylesheet" href="{}" />', { i(1, "style.css") })),
    s("script", fmt('<script src="{}"></script>', { i(1, "main.js") })),
    s("div", fmt('<div class="{}">\n    {}\n</div>', { i(1), i(0) })),
    s("ul", fmt("<ul>\n    <li>{}</li>\n</ul>", { i(0) })),
}
