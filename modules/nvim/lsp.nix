{pkgs, ...}: {
  programs.neovim = {
    extraPackages = with pkgs; [lua-language-server nil];
    plugins = with pkgs.vimPlugins; [nvim-lspconfig cmp-nvim-lsp];
    extraLuaConfig = ''
          local lspconfig = require('lspconfig')
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          -- Custom diagnostic signs using modern API (Neovim 0.10+/0.11)
          -- Falls back to legacy sign_define if nested signs.text config not supported.
          local diag_icons = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
          local configured = false
          do
            local ok = pcall(function()
              -- Attempt new style configuration (will error on very old versions)
              vim.diagnostic.config({
                signs = {
                  text = {
                    [vim.diagnostic.severity.ERROR] = diag_icons.Error,
                    [vim.diagnostic.severity.WARN]  = diag_icons.Warn,
                    [vim.diagnostic.severity.HINT]  = diag_icons.Hint,
                    [vim.diagnostic.severity.INFO]  = diag_icons.Info,
                  },
                },
              })
            end)
            if ok then configured = true end
          end
          if not configured then
            for t, icon in pairs(diag_icons) do
              local hl = 'DiagnosticSign' .. t
              pcall(vim.fn.sign_define, hl, { text = icon, texthl = hl, numhl = hl })
            end
          end

          local function on_attach(ev)
            local buf = ev.buf
            local function map(lhs, rhs, desc)
              vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
            end
      map('<leader>ln', vim.lsp.buf.rename, 'LSP Rename')
            map('<leader>la', vim.lsp.buf.code_action, 'LSP Code Action')
            map('<leader>ld', vim.lsp.buf.definition, 'LSP Definition')
            map('<leader>lD', vim.lsp.buf.declaration, 'LSP Declaration')
            map('<leader>li', vim.lsp.buf.implementation, 'LSP Implementation')
            map('<leader>lt', vim.lsp.buf.type_definition, 'LSP Type Definition')
      map('<leader>lR', vim.lsp.buf.references, 'LSP References')
            map('<leader>lh', vim.lsp.buf.hover, 'LSP Hover')
            map('<leader>ls', vim.lsp.buf.signature_help, 'LSP Signature Help')
            map('<leader>lf', function()
              vim.lsp.buf.format({ async = true })
            end, 'LSP Format Buffer')
          end
          lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach, settings = { Lua = { completion = { callSnippet = 'Replace' } } } })
          lspconfig.nil_ls.setup({ capabilities = capabilities, on_attach = on_attach })
          -- Merge/extend existing diagnostic settings without overwriting signs if already set above
          local current = vim.diagnostic.config() or {}
          vim.diagnostic.config(vim.tbl_deep_extend('force', current, {
            severity_sort = true,
            virtual_text = { spacing = 2, source = 'if_many' },
            float = { border = 'rounded', source = 'if_many' },
          }))
    '';
  };
}
