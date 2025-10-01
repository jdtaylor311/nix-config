{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ nvim-autopairs indent-blankline-nvim mini-nvim todo-comments-nvim conform-nvim nvim-lint guess-indent-nvim ];
    extraLuaConfig = ''
      require('nvim-autopairs').setup({})
      require('ibl').setup({})
      require('mini.ai').setup({ n_lines = 500 })
      require('mini.surround').setup()
      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      statusline.section_location = function() return '%2l:%-2v' end
      require('todo-comments').setup({ signs = false })
      require('conform').setup({
        notify_on_error = false,
        format_on_save = function(buf)
          local disable = { c = true, cpp = true }
          if disable[vim.bo[buf].filetype] then return end
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          nix = { 'alejandra' },
          sh = { 'shfmt' },
          javascript = { 'prettierd' },
          typescript = { 'prettierd' },
          json = { 'prettierd' },
          yaml = { 'prettierd' },
          markdown = { 'prettierd' },
        },
      })
      vim.keymap.set('n', '<leader>f', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, { desc = 'Format buffer' })
      local lint = require('lint')
      lint.linters_by_ft = { markdown = { 'markdownlint' } }
      local lint_grp = vim.api.nvim_create_augroup('nix-pure-lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_grp,
        callback = function() if vim.bo.modifiable then lint.try_lint() end end,
      })
    '';
  };
}
