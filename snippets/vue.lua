local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

-- fmt (not fmtd): TS `=>` / `<...>` would clash with fmtd's <> delimiters.
return {
    s(
        "sfc",
        fmt(
            [[<script setup lang="ts">
{}
</script>

<template>
    <div>{}</div>
</template>

<style scoped>
{}
</style>]],
            { i(1), i(2), i(0) }
        )
    ),
    s("ref", fmt("const {} = ref({});", { i(1, "value"), i(0) })),
    s("computed", fmt("const {} = computed(() => {});", { i(1, "value"), i(0) })),
    s(
        "watch",
        fmt(
            [[watch({}, ({}) => {{
    {}
}});]],
            { i(1, "source"), i(2, "value"), i(0) }
        )
    ),
    s(
        "onmounted",
        fmt(
            [[onMounted(() => {{
    {}
}});]],
            { i(0) }
        )
    ),
    s(
        "props",
        fmt(
            [[const props = defineProps<{{
    {}
}}>();]],
            { i(0) }
        )
    ),
}
