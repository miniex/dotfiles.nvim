-- Spell check across all filetypes; near-zero false positives.
return {
    -- Files only: no filetype filter, so it would also attach to oil:// listings
    -- (flagging file names) and other scheme / special buffers.
    root_dir = function(bufnr, on_dir)
        if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr):match("^%a[%w+.-]*://") then
            return
        end
        on_dir(vim.fs.root(bufnr, { "typos.toml", "_typos.toml", ".typos.toml", "pyproject.toml", "Cargo.toml" }))
    end,
    init_options = {
        -- Calmer than the default Warning.
        diagnosticSeverity = "Info",
    },
}
