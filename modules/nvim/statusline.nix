{
  pkgs,
  config,
  lib,
  ...
}: let
  trans = config.myThemes.neovimTransparent or true;
in {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [lualine-nvim nvim-web-devicons];
    extraLuaConfig = ''
      -- Dynamic statusline (lualine) with theme awareness & optional transparency
      local ok, lualine = pcall(require, 'lualine')
      if ok then
        local function pick_base_theme()
          local cs = (vim.g.colors_name or "")
          if cs:match('everforest') then return 'everforest' end
          if cs:match('tokyonight') then return 'tokyonight' end
          if cs:match('catppuccin') then return 'catppuccin' end
          return 'auto' -- lualine will guess
        end

        local function make_transparent(theme_name)
          if theme_name == 'auto' then return nil end
          local ok_theme, theme = pcall(require, 'lualine.themes.' .. theme_name)
          if not ok_theme then return nil end
          for _, mode_tbl in pairs(theme) do
            for _, section in pairs(mode_tbl) do
              if type(section) == 'table' and section.bg then
                section.bg = nil -- inherit terminal background
              end
            end
          end
          return theme
        end

        local base = pick_base_theme()
        local theme_tbl = nil
        if ${
        if trans
        then "true"
        else "false"
      } then
          theme_tbl = make_transparent(base)
        end
        if not theme_tbl then
          local ok_theme, theme = pcall(require, 'lualine.themes.' .. base)
          theme_tbl = ok_theme and theme or nil
        end
        local function diagnostics()
          return require('lualine.components.diagnostics'):extend()
        end
        if theme_tbl then
          lualine.setup({
            options = {
              theme = theme_tbl,
              section_separators = "",
              component_separators = "",
              globalstatus = true,
              disabled_filetypes = { 'neo-tree', 'starter' },
            },
            sections = {
              lualine_a = { 'mode' },
              lualine_b = { 'branch', { 'diff', symbols = { added = '+', modified = '~', removed = '-' } } },
              lualine_c = {
                { 'filename', path = 1, newfile_status = true, symbols = { modified = '', readonly = '' } },
              },
              lualine_x = { { 'diagnostics', sources = { 'nvim_diagnostic' }, sections = { 'error', 'warn', 'info', 'hint' }, symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' } }, 'encoding', 'fileformat', 'filetype' },
              lualine_y = { 'progress' },
              lualine_z = { 'location' },
            },
            inactive_sections = {
              lualine_a = {},
              lualine_b = {},
              lualine_c = { 'filename' },
              lualine_x = { 'location' },
              lualine_y = {},
              lualine_z = {},
            },
            extensions = { 'neo-tree', 'quickfix', 'fugitive' },
          })
        end
      end
    '';
  };
}
