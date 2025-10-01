{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [ lua-language-server nil ];
    plugins = with pkgs.vimPlugins; [ nvim-lspconfig cmp-nvim-lsp ];
    extraLuaConfig = ''
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Custom diagnostic signs (with icons)
      local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      local function on_attach(ev)
        local buf = ev.buf
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
        end
        map('<leader>lr', vim.lsp.buf.rename, 'LSP Rename')
        map('<leader>la', vim.lsp.buf.code_action, 'LSP Code Action')
        map('<leader>ld', vim.lsp.buf.definition, 'LSP Definition')
        map('<leader>lD', vim.lsp.buf.declaration, 'LSP Declaration')
        map('<leader>li', vim.lsp.buf.implementation, 'LSP Implementation')
        map('<leader>lt', vim.lsp.buf.type_definition, 'LSP Type Definition')
        map('<leader>lr', vim.lsp.buf.references, 'LSP References')
        map('<leader>lh', vim.lsp.buf.hover, 'LSP Hover')
        map('<leader>ls', vim.lsp.buf.signature_help, 'LSP Signature Help')
        map('<leader>lf', function()
          vim.lsp.buf.format({ async = true })
        end, 'LSP Format Buffer')
      end
      lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach, settings = { Lua = { completion = { callSnippet = 'Replace' } } } })
      lspconfig.nil_ls.setup({ capabilities = capabilities, on_attach = on_attach })
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, source = 'if_many' },
        float = { border = 'rounded', source = 'if_many' },
      })
    '';
  };
}
