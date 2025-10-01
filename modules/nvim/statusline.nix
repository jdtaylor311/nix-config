{
  pkgs,
  config,
  lib,
  ...
}: let
  # Transparency option (if true we lean on theme defaults, else enforce solid bg)
  trans = config.myThemes.neovimTransparent or true;
in {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [lualine-nvim nvim-web-devicons];
    extraLuaConfig = ''
      -- Dynamic statusline: build per-colorscheme lualine theme with colored mode sections.
      local ok, lualine = pcall(require, 'lualine')
      if not ok then return end

      local use_transparency = ${lib.boolToString trans}

      local function build_theme()
        local cs = vim.g.colors_name or ""
        local palette = {}
        -- Define base + accents per supported scheme
        if cs:match('catppuccin%-latte') then
          palette = {
            base = '#d5dbe1', surface = '#ccd2d8', text = '#303846',
            blue = '#1e66f5', green = '#40a02b', yellow = '#df8e1d', magenta = '#8839ef', red = '#d20f39'
          }
        elseif cs:match('catppuccin') then
          palette = {
            base = '#313244', surface = '#2b2d3a', text = '#cdd6f4',
            blue = '#89b4fa', green = '#a6e3a1', yellow = '#f9e2af', magenta = '#cba6f7', red = '#f38ba8'
          }
        elseif cs:match('everforest') then
          palette = {
            base = '#2f383e', surface = '#273037', text = '#d3c6aa',
            blue = '#7fbbb3', green = '#a7c080', yellow = '#dbb67f', magenta = '#d699b6', red = '#e67e80'
          }
        elseif cs:match('tokyonight') then
          palette = {
            base = '#292e42', surface = '#23273a', text = '#c0caf5',
            blue = '#7aa2f7', green = '#9ece6a', yellow = '#e0af68', magenta = '#bb9af7', red = '#f7768e'
          }
        else
          palette = {
            base = '#303030', surface = '#3a3a3a', text = '#ffffff',
            blue = '#61afef', green = '#98c379', yellow = '#e5c07b', magenta = '#c678dd', red = '#e06c75'
          }
        end

        local function seg(fg, bg, bold)
          return { fg = fg, bg = (use_transparency and nil or bg), gui = bold and 'bold' or nil }
        end
        local function mid()
          return { fg = palette.text, bg = (use_transparency and nil or palette.base) }
        end
        local function side()
          return { fg = palette.text, bg = (use_transparency and nil or palette.surface) }
        end

        return {
          normal =   { a = seg(palette.base, palette.blue, true),    b = side(), c = mid() },
          insert =   { a = seg(palette.base, palette.green, true),   b = side(), c = mid() },
          visual =   { a = seg(palette.base, palette.magenta, true), b = side(), c = mid() },
          replace =  { a = seg(palette.base, palette.red, true),     b = side(), c = mid() },
          command =  { a = seg(palette.base, palette.yellow, true),  b = side(), c = mid() },
          terminal = { a = seg(palette.base, palette.green, true),   b = side(), c = mid() },
          inactive = { a = side(), b = side(), c = mid() },
        }
      end

      local sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', { 'diff', symbols = { added = '+', modified = '~', removed = '-' } } },
        lualine_c = { { 'filename', path = 1, newfile_status = true, symbols = { modified = '', readonly = '' } } },
        lualine_x = { { 'diagnostics', sources = { 'nvim_diagnostic' }, sections = { 'error','warn','info','hint' }, symbols = { error=' ', warn=' ', info=' ', hint=' ' } }, 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      }

      local inactive_sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = { 'filename' },
        lualine_x = { 'location' }, lualine_y = {}, lualine_z = {},
      }

      local function apply_lualine()
        local theme = build_theme()
        lualine.setup({
          options = {
            theme = theme,
            section_separators = "",
            component_separators = "",
            globalstatus = true,
            disabled_filetypes = { 'neo-tree', 'starter' },
          },
          sections = sections,
          inactive_sections = inactive_sections,
          extensions = { 'neo-tree', 'quickfix', 'fugitive' },
        })
      end

      apply_lualine()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('StatuslineDynamicTheme', { clear = true }),
        callback = function() vim.schedule(apply_lualine) end,
      })
    '';
  };
}
