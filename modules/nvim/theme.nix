{ pkgs, lib, config, ... }:
let
  inherit (pkgs.vimPlugins) everforest tokyonight-nvim catppuccin-nvim;
  cfg = config.myThemes;
in {
  programs.neovim = {
    plugins = [ everforest tokyonight-nvim catppuccin-nvim ];
    extraLuaConfig = ''
      -- Base theme fallback (Everforest hard dark) with optional transparency
      vim.g.everforest_background = 'hard'
      if ${lib.boolToString cfg.neovimTransparent} then
        vim.g.everforest_transparent_background = 1
      end
      pcall(vim.cmd.colorscheme, 'everforest')

      -- Load dynamic theme override if present (written by sync-theme script)
      local dyn = vim.fn.stdpath('config') .. '/lua/theme_dynamic.lua'
      if vim.uv or vim.loop then
        local stat = (vim.uv or vim.loop).fs_stat(dyn)
        if stat then pcall(dofile, dyn) end
      end
    '';
  };
}

      -- Additional highlight tweaks to better mirror Ghostty minimal palette
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, 'Normal', { bg = '#1e1e2e', fg = '#cdd6f4' })
      set_hl(0, 'NormalFloat', { bg = '#1e1e2e', fg = '#cdd6f4' })
      set_hl(0, 'FloatBorder', { fg = '#585b70', bg = '#1e1e2e' })
      set_hl(0, 'Visual', { bg = '#313244' })
      set_hl(0, 'CursorLine', { bg = '#1f1f2f' })
      set_hl(0, 'LineNr', { fg = '#585b70' })
      set_hl(0, 'CursorLineNr', { fg = '#f5e0dc', bold = true })
      set_hl(0, 'Comment', { fg = '#585b70', italic = false })
      set_hl(0, 'Pmenu', { bg = '#242436', fg = '#cdd6f4' })
      set_hl(0, 'PmenuSel', { bg = '#313244', fg = '#f5e0dc' })
      set_hl(0, 'Search', { bg = '#f9e2af', fg = '#1e1e2e', bold = true })
      set_hl(0, 'IncSearch', { bg = '#f38ba8', fg = '#1e1e2e', bold = true })
      set_hl(0, 'StatusLine', { bg = '#1e1e2e', fg = '#cdd6f4' })
      set_hl(0, 'StatusLineNC', { bg = '#1e1e2e', fg = '#585b70' })
      set_hl(0, 'WinSeparator', { fg = '#313244' })
      set_hl(0, 'DiagnosticError', { fg = '#f38ba8' })
      set_hl(0, 'DiagnosticWarn', { fg = '#f9e2af' })
      set_hl(0, 'DiagnosticInfo', { fg = '#89b4fa' })
      set_hl(0, 'DiagnosticHint', { fg = '#94e2d5' })
    '';
  };
}
