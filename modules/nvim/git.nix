{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ gitsigns-nvim ];
    extraLuaConfig = ''
      require('gitsigns').setup({
        signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' } },
      })
    '';
  };
}
