local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt
-- fmt with `{{`/`}}` for literal braces (PHP's `<?php`/`<` rules out fmtd's `<>`).

return {
    -- <?php with strict types
    s("php", fmt("<?php\n\ndeclare(strict_types=1);\n\n{}", { i(0) })),
    -- class
    s("cls", fmt("class {} {{\n    {}\n}}", { i(1, "Name"), i(0) })),
    -- public / private method
    s("fn", fmt("public function {}({}): {} {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "void"), i(0) })),
    s("pfn", fmt("private function {}({}): {} {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "void"), i(0) })),
    -- constructor with promoted property
    s("ctor", fmt("public function __construct(\n    private {} ${},\n) {{}}", { i(1, "Type"), i(0, "name") })),
    -- foreach / if
    s("fore", fmt("foreach (${} as ${}) {{\n    {}\n}}", { i(1, "items"), i(2, "item"), i(0) })),
    s("if", fmt("if ({}) {{\n    {}\n}}", { i(1, "$cond"), i(0) })),
    -- namespace
    s("ns", fmt("namespace {};", { i(0, "App") })),
    -- PHPUnit test method
    s("test", fmt("public function test{}(): void {{\n    {}\n}}", { i(1, "Name"), i(0, "$this->assertTrue(true);") })),
}
