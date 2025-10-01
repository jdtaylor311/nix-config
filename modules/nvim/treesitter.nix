{pkgs, ...}: let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [p.lua p.vim p.markdown p.bash]);
in {
  programs.neovim = {
    plugins = [treesitter];
    extraLuaConfig = ''
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })
    '';
  };
}
