-- Default theme: vesper (Lua port of the VS Code "Vesper" theme).
-- Also registers <leader>st for the live-preview theme switcher.
-- Other theme files in lua/plugins/ (e.g. miasma) stay installed and
-- selectable, but are no longer applied on startup.
return {
  {
    "datsfilipe/vesper.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vesper").setup({})

      -- default colorscheme for the session
      vim.cmd.colorscheme("vesper")

      -- interactive theme switcher with live preview
      vim.keymap.set("n", "<leader>st", require("config.theme-switcher").open, {
        desc = "Swap Theme (live preview)",
      })
    end,
  },
}
