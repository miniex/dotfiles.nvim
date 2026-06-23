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
    s("input", fmt('<input type="{}" name="{}" placeholder="{}" />', { i(1, "text"), i(2, "name"), i(0) })),
    s("form", fmt('<form action="{}" method="{}">\n    {}\n</form>', { i(1), i(2, "post"), i(0) })),
    s(
        "table",
        fmt(
            [[<table>
    <thead>
        <tr><th>{}</th></tr>
    </thead>
    <tbody>
        <tr><td>{}</td></tr>
    </tbody>
</table>]],
            { i(1, "Header"), i(0) }
        )
    ),
    s(
        "picture",
        fmt(
            [[<picture>
    <source srcset="{}" media="{}" />
    <img src="{}" alt="{}" />
</picture>]],
            { i(1, "image.webp"), i(2, "(min-width: 768px)"), i(3, "image.jpg"), i(0) }
        )
    ),
}
