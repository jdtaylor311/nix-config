{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ which-key-nvim ];
    extraLuaConfig = ''
      local wk_ok, wk = pcall(require, 'which-key')
      if wk_ok then
        wk.setup({
          plugins = { spelling = true },
          window = { border = 'rounded' },
        })
        wk.register({
          ["<leader>"] = {
            f = { name = "+file" },
            g = { name = "+git" },
            l = { name = "+lsp" },
            d = { name = "+debug" },
            t = { name = "+toggle" },
          },
        })
      end
    '';
  };
}
