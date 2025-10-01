{ pkgs, ... }: let
  inherit (pkgs.vimPlugins) tokyonight-nvim;
in {
  programs.neovim = {
    plugins = [ tokyonight-nvim ];
    extraLuaConfig = ''
      require('tokyonight').setup({ styles = { comments = { italic = false } } })
      vim.cmd.colorscheme('tokyonight-night')
    '';
  };
}
