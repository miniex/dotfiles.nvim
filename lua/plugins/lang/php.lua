-- intelephense via lang_servers.
return {
    require("config.lang").treesitter({ "php", "phpdoc", "html" }),
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
    require("config.lang").mason({ "phpstan" }),
    require("config.lang").lint({ php = { "phpstan" } }),
    require("config.lang").neotest("olimorris/neotest-phpunit", function()
        return require("neotest-phpunit")
    end),
}
