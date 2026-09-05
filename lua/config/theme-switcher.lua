-- Interactive theme switcher with live preview, opened via <leader>st.
--
-- Uses Telescope's builtin.colorscheme picker when Telescope is available
-- (with a custom code-sample preview buffer), and falls back to a native
-- two-panel floating window (themes list | preview) otherwise.
--
-- Behaviour:
--   * moving over any entry applies that colorscheme instantly (no <CR> needed)
--   * <CR>       keeps the currently hovered theme for the session and closes
--   * <Esc>/<C-c> restores the colorscheme that was active before opening
--
-- State is kept local to this module; invalid colorschemes are pcall-guarded
-- and revert to the last known-good theme instead of crashing.

local M = {}

local PREVIEW_BUFNAME = "theme-switcher://preview"

-- Code template shown in the preview panel (functions, variables, comments,
-- strings, numbers, booleans and type annotations).
M.SAMPLE_CODE = {
  "----------------------------------------------------------------------",
  "-- Live theme preview: hover a colorscheme to apply it instantly.",
  "----------------------------------------------------------------------",
  "",
  "---@class Theme  Descriptor for an editor palette.",
  "---@field name  string   colorscheme name",
  "---@field dark  boolean  true when background is dark",
  "local Theme = {}",
  "Theme.__index = Theme",
  "",
  "local BUILTINS = { \"vesper\", \"miasma\", \"habamax\" }",
  "local MAX_RETRIES = 3",
  "local cache = {}",
  "",
  "---Creates a new theme descriptor.",
  "---@param name string",
  "---@return Theme",
  "function Theme.new(name)",
  "  local dark = vim.o.background == \"dark\"",
  "  return setmetatable({ name = name, dark = dark }, Theme)",
  "end",
  "",
  "---Applies the theme and remembers it on success.",
  "---@return boolean ok",
  "function Theme:apply()",
  "  local ok = pcall(vim.cmd.colorscheme, self.name)",
  "  if ok then",
  "    self:remember()",
  "    vim.notify(('switched to %q'):format(self.name), vim.log.levels.INFO)",
  "  else",
  "    vim.notify('failed to load: ' .. self.name, vim.log.levels.WARN)",
  "  end",
  "  return ok",
  "end",
  "",
  "function Theme:remember()",
  "  cache[self.name] = {",
  "    tags = { \"editor\", \"ui\" },",
  "    retries = MAX_RETRIES,",
  "    fallback = BUILTINS[1],",
  "  }",
  "end",
  "",
  "return Theme",
}

---Applies a colorscheme safely. On failure notifies and restores the
---last known-good colorscheme instead of leaving broken state behind.
---@param name string colorscheme name
---@return boolean ok
function M.apply(name)
  if type(name) ~= "string" or name == "" or name == vim.g.colors_name then
    return vim.g.colors_name ~= nil
  end

  local ok, err = pcall(vim.cmd.colorscheme, name)
  if ok then
    M._last_good = name
    return true
  end

  vim.notify(("Colorscheme %q failed to load (%s)"):format(name, err), vim.log.levels.WARN)
  if M._last_good and vim.g.colors_name ~= M._last_good then
    pcall(vim.cmd.colorscheme, M._last_good)
  end
  return false
end

local function telescope_previewer()
  local previewers = require("telescope.previewers")

  return previewers.new_buffer_previewer({
    title = "Preview",
    get_buffer_by_name = function()
      return PREVIEW_BUFNAME
    end,
    define_preview = function(self)
      local bufnr = self.state.bufnr
      if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
        return
      end
      -- the buffer is reused for every entry: only fill it once
      if not vim.b[bufnr].theme_switcher_filled then
        vim.b[bufnr].theme_switcher_filled = true
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.SAMPLE_CODE)
        vim.bo[bufnr].filetype = "lua"
      end
    end,
  })
end

---@return boolean opened whether the Telescope picker could be opened
local function telescope_picker()
  if not pcall(require, "telescope") then
    return false
  end
  local ok_builtin, builtin = pcall(require, "telescope.builtin")
  if not ok_builtin then
    return false
  end

  -- theme active before the picker was opened (restored on cancel)
  local initial = vim.g.colors_name or "default"

  local ok, err = pcall(builtin.colorscheme, {
    prompt_title = "Swap Theme",
    enable_preview = true,
    ignore_builtins = false,
    previewer = telescope_previewer(),
    layout_config = {
      horizontal = { preview_width = 0.55 },
    },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- <CR>: keep the hovered theme, then close
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry and entry.value then
          M.apply(entry.value)
        end
      end)

      -- <Esc>/<C-c>: restore the pre-picker theme, then close
      local function cancel(bufnr)
        pcall(vim.cmd.colorscheme, initial)
        M._last_good = initial
        actions.close(bufnr)
      end
      map({ "n", "i" }, "<Esc>", cancel)
      map({ "n", "i" }, "<C-c>", cancel)

      return true
    end,
  })
  if not ok then
    vim.notify(("Theme switcher (Telescope) failed: %s"):format(err), vim.log.levels.WARN)
    return false
  end
  return true
end

---@return boolean opened whether the native picker could be opened
local function native_picker()
  local themes = vim.fn.getcompletion("", "color")
  table.sort(themes)
  if #themes == 0 then
    vim.notify("No colorschemes found", vim.log.levels.WARN)
    return false
  end

  local initial = vim.g.colors_name or "default"

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local list_width = math.max(28, math.floor(width * 0.35))
  local preview_width = width - list_width
  local row = math.max(2, math.floor((vim.o.lines - height) / 2))
  local col = math.floor((vim.o.columns - width) / 2)

  local list_buf = vim.api.nvim_create_buf(false, true)
  local preview_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, themes)
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, M.SAMPLE_CODE)

  for _, b in ipairs({ list_buf, preview_buf }) do
    vim.bo[b].buftype = "nofile"
    vim.bo[b].bufhidden = "wipe"
    vim.bo[b].swapfile = false
    vim.bo[b].modifiable = false
  end
  vim.bo[preview_buf].filetype = "lua"

  local list_win = vim.api.nvim_open_win(list_buf, true, {
    relative = "editor",
    width = list_width,
    height = height,
    row = row,
    col = col,
    anchor = "NW",
    border = "rounded",
    style = "minimal",
    title = " Swap Theme ",
    title_pos = "center",
  })

  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    width = preview_width,
    height = height,
    row = row,
    col = col + list_width,
    anchor = "NW",
    border = "rounded",
    style = "minimal",
    title = " Preview ",
    title_pos = "center",
  })

  -- "minimal" disables these; re-enable for UX
  vim.wo[list_win].cursorline = true
  vim.wo[list_win].wrap = false
  vim.wo[preview_win].wrap = false

  -- start hovered on the currently active theme
  for i, name in ipairs(themes) do
    if name == initial then
      pcall(vim.api.nvim_win_set_cursor, list_win, { i, 0 })
      break
    end
  end

  local closed = false
  local aug = vim.api.nvim_create_augroup("theme_switcher_native", { clear = true })

  local function hovered()
    local lnum = vim.api.nvim_win_get_cursor(list_win)[1]
    return themes[lnum]
  end

  local function close()
    if closed then
      return
    end
    closed = true
    pcall(vim.api.nvim_del_augroup_by_id, aug)
    for _, w in ipairs({ list_win, preview_win }) do
      if vim.api.nvim_win_is_valid(w) then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
    -- list/preview buffers use bufhidden=wipe and die with their windows
  end

  local function keep()
    local name = hovered()
    close()
    if name then
      M.apply(name)
    end
  end

  local function cancel()
    close()
    pcall(vim.cmd.colorscheme, initial)
    M._last_good = initial
  end

  -- live preview: apply whatever entry the cursor is currently on
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = aug,
    buffer = list_buf,
    callback = function()
      M.apply(hovered())
    end,
  })

  -- emergency exit if a panel is closed by other means (e.g. <C-w>c)
  vim.api.nvim_create_autocmd("WinClosed", {
    group = aug,
    pattern = table.concat({ list_win, preview_win }, ","),
    callback = function()
      if not closed then
        cancel()
      end
    end,
  })

  local map_opts = { buffer = list_buf, silent = true, nowait = true }
  vim.keymap.set("n", "<CR>", keep, map_opts)
  vim.keymap.set("n", "<Esc>", cancel, map_opts)
  vim.keymap.set("n", "<C-c>", cancel, map_opts)
  vim.keymap.set("n", "q", cancel, map_opts)

  return true
end

---Opens the theme switcher (Telescope when available, native fallback otherwise).
function M.open()
  M._last_good = vim.g.colors_name or "default"
  if telescope_picker() then
    return
  end
  native_picker()
end

return M
