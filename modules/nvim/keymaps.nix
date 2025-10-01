{...}: {
  programs.neovim.extraLuaConfig = ''
    -- Basic window & UX keymaps
    local map = vim.keymap.set
    map('n', '<Esc>', '<cmd>nohlsearch<CR>')
    map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
    map('n', '<C-h>', '<C-w><C-h>')
    map('n', '<C-l>', '<C-w><C-l>')
    map('n', '<C-j>', '<C-w><C-j>')
    map('n', '<C-k>', '<C-w><C-k>')
  '';
}
