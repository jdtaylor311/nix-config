-- vim-fugitive keymaps
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Fugitive: Git status' })
vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<CR>', { desc = 'Fugitive: Git diff' })
vim.keymap.set('n', '<leader>gb', ':Gblame<CR>', { desc = 'Fugitive: Git blame' })
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Fugitive: Git commit' })
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Fugitive: Git push' })
vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { desc = 'Fugitive: Git pull' })
vim.keymap.set('n', '<leader>gq', ':Gedit<CR>', { desc = 'Fugitive: Quit fugitive buffer' })
