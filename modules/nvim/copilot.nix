{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    # Remove copilot-lua / copilot-cmp. We'll rely on the official language server.
    plugins = with pkgs.vimPlugins; [];
    extraPackages = [ pkgs.copilot-language-server ];
    extraLuaConfig = ''
      -- Official GitHub Copilot Language Server integration
      -- Requires auth via: :lua require('copilot_auth').auth() OR external CLI sign-in.
      -- We'll auto-start it globally and expose status + sign-in helpers.

      local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
      if lspconfig_ok then
        -- Minimal capabilities (augment later if cmp present)
        local caps = vim.lsp.protocol.make_client_capabilities()
        -- Inline completion (Neovim >= 0.12) enable if available
        pcall(function()
          if vim.lsp.inline_completion then
            vim.lsp.inline_completion.enable()
          end
        end)
        lspconfig.copilot.setup({
          capabilities = caps,
          handlers = {},
          on_attach = function(client, bufnr)
            -- Keymaps specific to Copilot LSP
            local km = function(lhs, rhs, desc)
              vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
            end
            km('<leader>lc', function()
              vim.notify('Copilot: ' .. (client.name or 'connected'), vim.log.levels.INFO)
            end, 'Copilot LSP Info')
          end,
        })
      end

      -- Helper module for auth (wrapping CLI flow)
      local M = {}
      function M.auth()
        -- Try spawning the CLI auth if available
        if vim.fn.executable('github-copilot-cli') == 1 then
          vim.notify('Starting Copilot CLI auth...', vim.log.levels.INFO)
          vim.fn.jobstart({ 'github-copilot-cli', 'auth' }, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                for _, line in ipairs(data) do
                  if line ~= "" then vim.notify(line) end
                end
              end
            end,
            on_exit = function() vim.notify('Copilot auth process exited') end,
          })
        else
          vim.notify('github-copilot-cli not in PATH', vim.log.levels.ERROR)
        end
      end
      package.loaded['copilot_auth'] = M

      -- Which-key style command (fallback if which-key not yet loaded)
      vim.api.nvim_create_user_command('CopilotAuth', function() require('copilot_auth').auth() end, {})
    '';
  };
}
