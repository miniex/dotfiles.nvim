local u = require("config.snippets")
-- `f` uses `<>` delimiters so Go-template `{{ }}` stays literal.
local s, i, f = u.s, u.i, u.fmtd

return {
    s("val", f("{{ .Values.<> }}", { i(0, "key") })),
    s("rel", f("{{ .Release.<> }}", { i(0, "Name") })),
    s("inc", f('{{ include "<>" . }}', { i(0, "chart.labels") })),
    s("tpl", f("{{ tpl <> . }}", { i(0, ".Values.text") })),
    s("def", f('{{- define "<>" -}}\n<>\n{{- end -}}', { i(1, "chart.name"), i(0) })),
    s("if", f("{{- if <> }}\n<>\n{{- end }}", { i(1, ".Values.enabled"), i(0) })),
    s("with", f("{{- with <> }}\n<>\n{{- end }}", { i(1, ".Values.config"), i(0) })),
    s("range", f("{{- range <> }}\n<>\n{{- end }}", { i(1, ".Values.items"), i(0) })),
    s("toyaml", f("{{- toYaml <> | nindent <> }}", { i(1, ".Values.resources"), i(0, "4") })),
    s("def-key", f('{{ default "<>" .Values.<> }}', { i(1, "fallback"), i(0, "key") })),
}
