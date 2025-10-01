{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ telescope-nvim telescope-fzf-native-nvim telescope-ui-select-nvim plenary-nvim neo-tree-nvim nui-nvim nvim-web-devicons ];
    extraLuaConfig = ''
      local telescope = require('telescope')
      telescope.setup({ extensions = { ['ui-select'] = require('telescope.themes').get_dropdown() } })
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      local tb = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', tb.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sf', tb.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', tb.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sb', tb.buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sd', tb.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { silent = true, desc = 'Neo-tree reveal' })
      require('neo-tree').setup({ filesystem = { window = { mappings = { ['\\'] = 'close_window' } } } })
    '';
  };
}
