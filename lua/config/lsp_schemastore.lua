-- Shared SchemaStore.nvim wiring for jsonls/yamlls before_init: each language's
-- schemas are fetched once (cached), pcall-guarded so a load failure is schema-less.
local M = {}

local cache = {}

local function schemas(lang)
    if cache[lang] == nil then
        local ok, result = pcall(function()
            return require("schemastore")[lang].schemas()
        end)
        cache[lang] = ok and result or {}
    end
    return cache[lang]
end

-- json.schemas() is an array → append.
function M.json(config)
    config.settings.json.schemas = config.settings.json.schemas or {}
    vim.list_extend(config.settings.json.schemas, schemas("json"))
end

-- yaml.schemas() is a map → merge.
function M.yaml(config)
    config.settings.yaml.schemas = vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, schemas("yaml"))
end

-- taplo 0.10.0 rejects SchemaStore's catalog: it requires `$schema` to be the old
-- json.schemastore.org URL (fixed upstream, unreleased). Skip the catalog and feed
-- its *.toml fileMatch globs as associations (regex on the document URI).
local function glob_to_regex(glob)
    local out = glob:gsub("%*%*/", "\0"):gsub("[%^%$%(%)%%%.%[%]%+%?%{%}|\\]", "\\%0")
    return "(^|/)" .. out:gsub("%*", "[^/]*"):gsub("%z", "(.*/)?") .. "$"
end
-- Mutates config.settings in place: the client keeps a reference to that table.
function M.toml(config)
    config.settings = config.settings or {}
    config.settings.evenBetterToml = config.settings.evenBetterToml or {}
    local schema = config.settings.evenBetterToml.schema or {}
    config.settings.evenBetterToml.schema = schema
    schema.catalogs = {}
    schema.associations = schema.associations or {}
    for _, s in ipairs(schemas("json")) do
        for _, f in ipairs(s.fileMatch or {}) do
            if f:match("%.toml$") then
                schema.associations[glob_to_regex(f)] = schema.associations[glob_to_regex(f)] or s.url
            end
        end
    end
end

return M
