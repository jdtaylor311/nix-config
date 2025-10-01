{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [telescope-nvim telescope-fzf-native-nvim telescope-ui-select-nvim plenary-nvim neo-tree-nvim nui-nvim nvim-web-devicons];
    extraLuaConfig = ''
          local telescope = require('telescope')
          telescope.setup({ extensions = { ['ui-select'] = require('telescope.themes').get_dropdown() } })
          pcall(telescope.load_extension, 'fzf')
          pcall(telescope.load_extension, 'ui-select')
          local tb = require('telescope.builtin')
      -- Consolidate search under <leader>f prefix to avoid raw <Space> collisions in which-key reports
      vim.keymap.set('n', '<leader>fh', tb.help_tags, { desc = 'Find Help' })
      vim.keymap.set('n', '<leader>ff', tb.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', tb.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fb', tb.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fd', tb.diagnostics, { desc = 'Diagnostics' })
      -- Move Neo-tree to <leader>e to avoid bare backslash overlap
      vim.keymap.set('n', '<leader>e', ':Neotree reveal<CR>', { silent = true, desc = 'Neo-tree reveal' })
      require('neo-tree').setup({ filesystem = { window = { mappings = { ['e'] = 'close_window' } } } })
    '';
  };
}
