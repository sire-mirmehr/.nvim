return {
  'nvimtools/none-ls.nvim',
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup {

      sources = {
        -- =========================
        -- FORMATTERS
        -- =========================

        null_ls.builtins.formatting.yamlfmt,
        null_ls.builtins.formatting.cmake_format,
        null_ls.builtins.formatting.prettier,
        -- ruff formatting handled by ruff LSP in lsp-config.lua
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.xmllint,

        -- Go formatters
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.golines,

        -- =========================
        -- DIAGNOSTICS / LINTERS
        -- =========================

        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.cmake_lint,
        -- null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.hadolint,
        -- null_ls.builtins.diagnostics.ruff,
        null_ls.builtins.diagnostics.stylelint,
        null_ls.builtins.diagnostics.yamllint,

        -- Go linters
        null_ls.builtins.diagnostics.staticcheck,
        null_ls.builtins.diagnostics.golangci_lint,
      },
    }
    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
  end,
}
