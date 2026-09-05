return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      require('nvim-treesitter').install {
        -- Neovim / Lua
        'lua',
        'vim',

        -- JavaScript / TypeScript / React / Next.js
        'javascript',
        'typescript',
        'tsx',

        -- Web
        'html',
        'css',

        -- Markdown
        'markdown',

        -- JSON
        'json',

        -- YAML / Ansible
        'yaml',

        -- Docker
        'dockerfile',

        -- C / C++
        'c',
        'cpp',

        -- C#
        'c_sharp',

        -- Python
        'python',

        -- Bash
        'bash',

        -- XML / Avalonia XAML
        'xml',

        -- Rust
        'rust',

        -- Go
        'go',
      }
    end,
  },
}
