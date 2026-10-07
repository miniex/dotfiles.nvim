-- Empty on purpose: native ft detection + the central treesitter grammar cover RON.
-- The file stays so the `ron` lang toggle has a module to import.
return {
    require("config.lang").treesitter({ "ron" }),
}
