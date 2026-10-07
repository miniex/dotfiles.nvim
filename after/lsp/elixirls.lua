return {
    settings = {
        elixirLS = {
            -- Off: dialyzer's PLT build is ElixirLS's heaviest task; enable per-project if needed.
            dialyzerEnabled = false,
            dialyzerFormat = "dialyxir_long",
            enableTestLenses = true,
            suggestSpecs = true,
            fetchDeps = false,
            signatureAfterComplete = true,
        },
    },
}
