-- Grammar (php, phpdoc) lives in the base treesitter list; intelephense via lang_servers.
return {
    require("config.lang").mason({ "php-debug-adapter" }),
    require("config.dap").spec(function(dap)
        local cmd = require("config.dap").mason_bin("bin/php-debug-adapter", "php-debug-adapter")
        if not cmd then
            return
        end
        dap.adapters.php = { type = "executable", command = cmd }
        dap.configurations.php = {
            {
                -- Needs Xdebug in PHP: xdebug.mode=debug, xdebug.client_port=9003.
                type = "php",
                request = "launch",
                name = "Listen for Xdebug",
                port = 9003,
            },
        }
    end),
}
