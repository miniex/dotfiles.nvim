-- classRegex teaches the LSP about utility wrappers (cva / clsx / cn / tw).
return {
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "tw`([^`]*)" },
                    { 'tw="([^"]*)' },
                    { 'tw={"([^"}]*)' },
                },
            },
        },
    },
}
