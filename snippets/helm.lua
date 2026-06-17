local u = require("config.snippets")
-- fmtd uses `<>` delimiters so Go-template `{{ }}` stays literal.
local s, i, fmtd = u.s, u.i, u.fmtd

return {
    s("val", fmtd("{{ .Values.<> }}", { i(0, "key") })),
    s("rel", fmtd("{{ .Release.<> }}", { i(0, "Name") })),
    s("inc", fmtd('{{ include "<>" . }}', { i(0, "chart.labels") })),
    s("tpl", fmtd("{{ tpl <> . }}", { i(0, ".Values.text") })),
    s("def", fmtd('{{- define "<>" -}}\n<>\n{{- end -}}', { i(1, "chart.name"), i(0) })),
    s("if", fmtd("{{- if <> }}\n<>\n{{- end }}", { i(1, ".Values.enabled"), i(0) })),
    s("with", fmtd("{{- with <> }}\n<>\n{{- end }}", { i(1, ".Values.config"), i(0) })),
    s("range", fmtd("{{- range <> }}\n<>\n{{- end }}", { i(1, ".Values.items"), i(0) })),
    s("toyaml", fmtd("{{- toYaml <> | nindent <> }}", { i(1, ".Values.resources"), i(0, "4") })),
    s("def-key", fmtd('{{ default "<>" .Values.<> }}', { i(1, "fallback"), i(0, "key") })),
}
