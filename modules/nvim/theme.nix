{ pkgs, lib, ... }: let
  inherit (pkgs.vimPlugins) everforest;
in {
  programs.neovim = {
    plugins = [ everforest ];
    extraLuaConfig = ''
      -- Everforest theme config to align with Ghostty (everforest-dark hard)
      -- Ghostty palette reference (from themes/everforest-dark):
      -- bg: #2b3339  fg: #d3c6aa  accents: e67e80 a7c080 dbbc7f 7fbbb3 d699b6 83c092

      -- Everforest options (see :h everforest or repo docs)
      vim.g.everforest_background = 'hard'
      vim.g.everforest_enable_italic = 0
      vim.g.everforest_better_performance = 1
      -- If you prefer transparency in Neovim to match Ghostty opacity:
      -- vim.g.everforest_transparent_background = 1

      vim.cmd.colorscheme('everforest')

      -- Fine-tune to match the custom terminal palette exactly
      local override_bg = '#2b3339'
      local override_fg = '#d3c6aa'
      local hl = vim.api.nvim_set_hl
      hl(0, 'Normal',       { bg = override_bg, fg = override_fg })
      hl(0, 'NormalNC',     { bg = override_bg, fg = override_fg })
      hl(0, 'NormalFloat',  { bg = override_bg })
      hl(0, 'SignColumn',   { bg = override_bg })
      hl(0, 'LineNr',       { bg = override_bg })
      hl(0, 'FoldColumn',   { bg = override_bg })
      hl(0, 'StatusLine',   { fg = override_fg })
      hl(0, 'WinSeparator', { fg = '#374247', bg = override_bg })

      -- Subtle visual selection background similar to Ghostty selection (#374247)
      hl(0, 'Visual', { bg = '#374247' })

      -- Diagnostic virtual text tweak (slightly dimmer)
      for _, sev in ipairs({ 'Error', 'Warn', 'Info', 'Hint' }) do
        local group = 'DiagnosticVirtualText' .. sev
        local ok, def = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if ok then
          def.bg = '#323c41'
          hl(0, group, def)
        end
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
