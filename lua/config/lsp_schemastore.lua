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

return M
