return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          keys = {
            {
              "gD",
              function()
                local params = vim.lsp.util.make_position_params()
                vim.lsp.buf_request(0, "workspace/executeCommand", {
                  command = "typescript.goToSourceDefinition",
                  arguments = { params.textDocument.uri, params.position },
                })
              end,
              desc = "Goto Source Definition",
            },
            {
              "gR",
              function()
                vim.lsp.buf_request(0, "workspace/executeCommand", {
                  command = "typescript.findAllFileReferences",
                  arguments = { vim.uri_from_bufnr(0) },
                })
              end,
              desc = "File References",
            },
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  context = { only = { "source.organizeImports" } },
                  apply = true,
                })
              end,
              desc = "Organize Imports",
            },
            {
              "<leader>cM",
              function()
                vim.lsp.buf.code_action({
                  context = { only = { "source.addMissingImports.ts" } },
                  apply = true,
                })
              end,
              desc = "Add missing imports",
            },
            {
              "<leader>cu",
              function()
                vim.lsp.buf.code_action({
                  context = { only = { "source.removeUnused.ts" } },
                  apply = true,
                })
              end,
              desc = "Remove unused imports",
            },
          },
        },
      },
      setup = {
        vtsls = function(_, opts)
          opts.settings.javascript = vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },
}