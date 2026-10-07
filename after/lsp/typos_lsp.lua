-- Spell check across all filetypes; near-zero false positives.
return {
    init_options = {
        -- Calmer than the default Warning.
        diagnosticSeverity = "Info",
    },
}
