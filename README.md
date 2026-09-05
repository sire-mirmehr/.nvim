# .nvim

Personal Neovim configuration built on [lazy.nvim](https://github.com/folke/lazy.nvim) — Lua only, one plugin spec file per concern in `lua/plugins/`.

## Requirements

- Neovim **>= 0.11** (tested on 0.12) — uses `vim.lsp.config` / `vim.lsp.enable`
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `git` (lazy.nvim bootstrap)
- External binaries for formatters/linters (`stylua`, `prettier`, `gofumpt`, `shellcheck`, …) — LSP servers install via `:Mason`, but null-ls sources expect their executables on `PATH`

## Install

```sh
git clone https://github.com/ZeroTraceAmir/.nvim.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa   # install all plugins, then start nvim normally
```

## Highlights

- **Theme switcher** — `<leader>st` opens a Telescope picker (with a live code-sample preview pane, native float fallback) over all installed colorschemes. Hovering applies the theme instantly, `<CR>` keeps it for the session, `<Esc>`/`<C-c>` reverts to the theme that was active before opening.
- **Dashboard** — alpha startify with custom ASCII header
- **LSP** — Mason auto-installs ~18 servers (web, C/C++, C#, Python, Go, Rust, Bash, YAML/Ansible, Docker, XML); rust-analyzer uses clippy, gopls has full hints/codelenses; diagnostics float on cursor hold
- **Completion** — nvim-cmp + LuaSnip + friendly-snippets, bordered windows, Tab/S-Tab to cycle/expand
- **Formatting/linting** — none-ls (prettier, stylua, gofumpt/goimports/golines, yamlfmt, xmllint, staticcheck, golangci-lint, hadolint, …)

## Keymaps

`<leader>` is `Space`. Full list via `<leader>hk` (which-key popup).

| Key | Action |
| --- | --- |
| `<leader>st` | Swap theme (live preview) |
| `<leader>e` | Toggle Neo-tree (file explorer) |
| `<leader>ff` / `<leader>fg` | Telescope find files / live grep |
| `<leader>fb` / `<leader>fh` | Telescope buffers / help tags |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` / `<leader>b` | Close buffer / new empty buffer |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between windows (tmux-aware) |
| `<leader>v` / `<leader>h` | Vertical / horizontal split |
| `<S-Left/Right/Up/Down>` | Resize split |
| `<leader>t` | Toggle persistent terminal below |
| `<C-s>` / `<C-q>` | Save / quit |
| `<leader>sn` | Save without auto-formatting |
| `<C-d>` / `<C-u>` | Half-page scroll, centered |
| `n` / `N` | Next / previous match, centered |
| `<leader>gf` | Format buffer (null-ls) |
| `K` / `gd` / `gr` | LSP hover / definition / references |
| `<leader>ca` / `<leader>rn` | Code action / rename |
| `<leader>d` / `[d` / `]d` | Diagnostic float / prev / next |
| `<leader>do` / `<leader>q` | Toggle diagnostics / send to loclist |
| `<leader>y` / `<leader>p` | Yank / paste to system clipboard |
| `<leader>j` | Replace word under cursor (`*` + `cgn`) |
| `gcc` / `gc{motion}` | Comment (Neovim built-in) |

## Structure

```
lua/
  config/          # lazy.nvim bootstrap, options, keymaps, theme-switcher module
  plugins/         # one lazy.nvim spec per file, auto-imported alphabetically
```

Startup order: `init.lua` → `config/lazy.lua` (leader keys must be set here, *before* lazy.nvim) → all `lua/plugins/*.lua` specs → `config/keymaps.lua` → `config/options.lua`.

## Notes

- `vesper` is the startup default. Other themes (`miasma`, `lackluster`) are installed and selectable via `<leader>st` / `:colorscheme`, but deliberately never auto-applied — alphabetical file load order is what keeps vesper on top.
- `lua.old.folder/` and `*.old` files are local backups, git-ignored.
