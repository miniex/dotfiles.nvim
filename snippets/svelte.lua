local u = require("config.snippets")
local s, i, fmt, fmtd = u.s, u.i, u.fmt, u.fmtd

-- Reactive snippets are Svelte 5 runes; markup blocks work on 4 and 5.
return {
    s(
        "comp",
        fmt(
            [[<script lang="ts">
{}
</script>

<div>{}</div>

<style>
{}
</style>]],
            { i(1), i(2), i(0) }
        )
    ),
    s("state", fmt("let {} = $state({});", { i(1, "value"), i(0) })),
    s("derived", fmt("let {} = $derived({});", { i(1, "value"), i(0) })),
    s("props", fmtd([[let { <> } = $props();]], { i(0) })),
    s(
        "each",
        fmtd(
            [[{#each <> as <>}
    <>
{/each}]],
            { i(1, "items"), i(2, "item"), i(0) }
        )
    ),
    s(
        "if",
        fmtd(
            [[{#if <>}
    <>
{/if}]],
            { i(1, "condition"), i(0) }
        )
    ),
}
