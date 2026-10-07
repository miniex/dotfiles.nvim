-- Bundled root_markers = { "config.yml" } would latch onto any unrelated config.yml upward.
return {
    root_markers = { ".git" },
}
