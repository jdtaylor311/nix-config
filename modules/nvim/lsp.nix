{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = with pkgs; [ lua-language-server nil ];
    plugins = with pkgs.vimPlugins; [ nvim-lspconfig cmp-nvim-lsp ];
    extraLuaConfig = ''
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function on_attach(ev)
        local buf = ev.buf
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
        end
        map('grn', vim.lsp.buf.rename, 'LSP Rename')
        map('gra', vim.lsp.buf.code_action, 'LSP Code Action')
        map('grd', vim.lsp.buf.definition, 'LSP Definition')
        map('grr', vim.lsp.buf.references, 'LSP References')
        map('gri', vim.lsp.buf.implementation, 'LSP Impl')
        map('grt', vim.lsp.buf.type_definition, 'LSP Type Def')
      end
      lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach, settings = { Lua = { completion = { callSnippet = 'Replace' } } } })
      lspconfig.nil_ls.setup({ capabilities = capabilities, on_attach = on_attach })
      vim.diagnostic.config({ severity_sort = true, virtual_text = { spacing = 2, source = 'if_many' } })
    '';
  };
}
