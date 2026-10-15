-- return {
--   {
--     "williamboman/mason.nvim",
--     opts = {},
--   },
--   {
--     "williamboman/mason-lspconfig.nvim",
--     dependencies = {
--       "williamboman/mason.nvim",
--       "neovim/nvim-lspconfig",
--     },
--     opts = {
--       ensure_installed = {
--         "html",
--         "cssls",
--         "tailwindcss",
--         "vtsls",
--         "marksman",
--         "jsonls",
--         "yamlls",
--         "ansiblels",
--         "dockerls",
--         "clangd",
--         "omnisharp",
--         "pyright",
--         "ruff",
--         "lua_ls",
--         "bashls",
--       },
--     },
--   },
--   {
--     "neovim/nvim-lspconfig",
--     config = function()
--       local capabilities = require('cmp_nvim_lsp').default_capabilities()
--       -- Enable all installed servers automatically using Neovim 0.11 native API
--       local servers = {
--         "html", "cssls", "tailwindcss", "vtsls", "marksman",
--         "jsonls", "yamlls", "ansiblels", "dockerls", "clangd",
--         "omnisharp", "pyright", "ruff","lua_ls", "bashls"
--       }
--
--       for _, server in ipairs(servers) do
--         vim.lsp.enable(server)
--       end
--       vim.keymap.set('n','K',vim.lsp.buf.hover,{})
--       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
--       vim.keymap.set({ 'n' }, '<leader>ca', vim.lsp.buf.code_action, {})
--     end,
--   },
-- }
return {
  {
    'williamboman/mason.nvim',
    opts = {},
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },

    opts = {
      ensure_installed = {
        'html',
        'cssls',
        'tailwindcss',
        'vtsls',
        'marksman',
        'jsonls',
        'yamlls',
        'ansiblels',
        'dockerls',
        'clangd',
        'omnisharp',
        'pyright',
        'ruff',
        'lua_ls',
        'bashls',
        'lemminx',
        'rust_analyzer',
        'gopls',
      },
    },
  },

  {
    'neovim/nvim-lspconfig',

    config = function()
      -- Capabilities provided by nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Some linters publish ranges that end before they start. Neovim 0.12
      -- rejects those ranges while creating diagnostic extmarks.
      local diagnostic_set = vim.diagnostic.set
      vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
        for _, diagnostic in ipairs(diagnostics or {}) do
          if diagnostic.lnum and (not diagnostic.end_lnum or diagnostic.end_lnum < diagnostic.lnum) then
            diagnostic.end_lnum = diagnostic.lnum
            diagnostic.end_col = math.max(diagnostic.end_col or 0, diagnostic.col or 0)
          elseif diagnostic.lnum and diagnostic.end_lnum == diagnostic.lnum and diagnostic.end_col and diagnostic.col then
            diagnostic.end_col = math.max(diagnostic.end_col, diagnostic.col)
          end
        end

        return diagnostic_set(namespace, bufnr, diagnostics, opts)
      end

      local publish_diagnostics = vim.lsp.handlers['textDocument/publishDiagnostics']
      vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
        if result and result.diagnostics then
          for _, diagnostic in ipairs(result.diagnostics) do
            local start = diagnostic.range and diagnostic.range.start
            local finish = diagnostic.range and diagnostic.range['end']

            if start and (not finish or finish.line < start.line or (finish.line == start.line and finish.character < start.character)) then
              if diagnostic.range then
                diagnostic.range['end'] = {
                  line = start.line,
                  character = start.character,
                }
              end
            end
          end
        end

        return publish_diagnostics(err, result, ctx, config)
      end

      local servers = {
        'html',
        'cssls',
        'tailwindcss',
        'vtsls',
        'marksman',
        'jsonls',
        'yamlls',
        'ansiblels',
        'dockerls',
        'clangd',
        'omnisharp',
        'pyright',
        'ruff',
        'lua_ls',
        'bashls',
        'lemminx',
        'rust_analyzer',
        'gopls',
      }

      -- Rust: use clippy for diagnostics instead of default cargo check
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
            },
          },
        },
      })

      -- Go: gopls with full feature set
      vim.lsp.config('gopls', {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              unusedvariable = true,
            },
            codelenses = {
              generate = true,
              gc_details = true,
              test = true,
              tidy = true,
              vendor = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            deepCompletion = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
        })

        vim.lsp.enable(server)
      end

      -- Avalonia .axaml files treated as XML
      vim.filetype.add {
        extension = {
          axaml = 'xml',
        },
      }

      -- Keymaps
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {
        desc = 'LSP Hover',
      })

      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {
        desc = 'Go to definition',
      })

      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {
        desc = 'Code action',
      })

      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {
        desc = 'Rename symbol',
      })

      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {
        desc = 'Go to references',
      })

      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, {
        desc = 'Type definition',
      })

      vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, {
        desc = 'Go to implementation',
      })

      vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, {
        desc = 'Signature help',
      })

      -- Show line diagnostics in a float
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
        desc = 'Show line diagnostics',
      })

      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
        desc = 'Previous diagnostic',
      })

      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
        desc = 'Next diagnostic',
      })

      -- Auto-show diagnostics on cursor hold, close on cursor move
      vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable = false,
            scope = 'line',
            close_events = { 'CursorMoved', 'CursorMovedI', 'BufHidden', 'InsertEnter' },
          })
        end,
      })
    end,
  },
  
}
