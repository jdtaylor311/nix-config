{ pkgs, ... }: {
  programs.neovim.extraLuaConfig = ''
    -- Core options extracted
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ' '
    local o = vim.o
    o.number = true
    o.mouse = 'a'
    o.showmode = false
    vim.schedule(function() o.clipboard = 'unnamedplus' end)
    o.breakindent = true
    o.undofile = true
    o.ignorecase = true
    o.smartcase = true
    o.signcolumn = 'yes'
    o.updatetime = 250
    o.timeoutlen = 300
    o.splitright = true
    o.splitbelow = true
    o.list = true
    vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
    o.expandtab = true
    o.tabstop = 2
    o.shiftwidth = 2
    o.softtabstop = 2
    o.smartindent = true
    o.inccommand = 'split'
    o.cursorline = true
    o.scrolloff = 10
    o.confirm = true

    -- Yank highlight
    vim.api.nvim_create_autocmd('TextYankPost', {
      group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
      callback = function() vim.highlight.on_yank() end,
    })
  '';
}
