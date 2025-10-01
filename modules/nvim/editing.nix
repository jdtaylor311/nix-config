{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [nvim-autopairs indent-blankline-nvim mini-nvim todo-comments-nvim conform-nvim nvim-lint guess-indent-nvim];
    extraLuaConfig = ''
          require('nvim-autopairs').setup({})
          require('ibl').setup({})
          require('mini.ai').setup({ n_lines = 500 })
          -- Use a less collision-prone prefix for surround operations (gs*) to avoid which-key overlap noise
          require('mini.surround').setup({
            mappings = {
              add = 'gsa',
              delete = 'gsd',
              find = 'gsf',
              find_left = 'gsF',
              highlight = 'gsh',
              replace = 'gsr',
              update_n_lines = 'gsn',
            },
          })
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
      -- Use <leader>lf for format (namespaced under LSP group) to avoid broad <leader>f collisions
      vim.keymap.set('n', '<leader>lf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, { desc = 'Format buffer' })

          -- Project-wide formatting command
          vim.api.nvim_create_user_command('FormatProject', function()
            local conform_ok, conform = pcall(require, 'conform')
            if not conform_ok then vim.notify('Conform not available', vim.log.levels.ERROR); return end
            local has_fd = vim.fn.executable('fd') == 1
            local has_rg = vim.fn.executable('rg') == 1
            local cmd
            if has_fd then
              cmd = "fd --type f --hidden --exclude .git --exclude node_modules --exclude dist --exclude build"
            elseif has_rg then
              cmd = "rg --files --hidden -g '!.git' -g '!node_modules' -g '!dist' -g '!build'"
            else
              vim.notify('Neither fd nor rg is installed; cannot enumerate project files', vim.log.levels.ERROR)
              return
            end
            local files = vim.fn.systemlist(cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify('File enumeration failed', vim.log.levels.ERROR)
              return
            end
            local eligible_ext = { lua=true, py=true, nix=true, sh=true, js=true, ts=true, json=true, yaml=true, md=true, markdown=true }
            local total, formatted, skipped = 0, 0, 0
            for _, path in ipairs(files) do
              local ext = path:match('%.([%w]+)$')
              if ext == 'md' then ext = 'markdown' end
                if ext and eligible_ext[ext] then
                  total = total + 1
                  local bufnr = vim.fn.bufadd(path)
                  vim.fn.bufload(bufnr)
                  if vim.bo[bufnr].filetype == "" then
                    vim.cmd('filetype detect')
                  end
                  local ok = pcall(function()
                    conform.format({ bufnr = bufnr, async = false, lsp_format = 'fallback' })
                    if vim.api.nvim_buf_get_option(bufnr, 'modified') then
                      vim.api.nvim_buf_call(bufnr, function() vim.cmd('write') end)
                      formatted = formatted + 1
                    else
                      skipped = skipped + 1
                    end
                  end)
                  if not ok then skipped = skipped + 1 end
                end
            end
            vim.notify(string.format('FormatProject: %d formatted / %d skipped (eligible %d)', formatted, skipped, total))
          end, { desc = 'Format entire project with Conform' })

          vim.keymap.set('n', '<leader>fA', '<cmd>FormatProject<CR>', { desc = 'Format entire project' })
          local lint = require('lint')
          -- Only enable markdownlint if the executable exists to avoid ENOENT noise
          if vim.fn.executable('markdownlint') == 1 then
            lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft or {}, { markdown = { 'markdownlint' } })
          else
            vim.schedule(function()
              vim.notify('markdownlint CLI not found in PATH; markdown linting disabled', vim.log.levels.WARN)
            end)
          end
          local lint_grp = vim.api.nvim_create_augroup('nix-pure-lint', { clear = true })
          vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_grp,
            callback = function() if vim.bo.modifiable then lint.try_lint() end end,
          })
    '';
  };
}
