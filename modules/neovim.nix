{pkgs, ...}: {
  imports = [
    ./nvim/options.nix
    ./nvim/keymaps.nix
    ./nvim/theme.nix
    ./nvim/treesitter.nix
    ./nvim/lsp.nix
    ./nvim/completion.nix
    ./nvim/copilot.nix
    ./nvim/statusline.nix
    ./nvim/whichkey.nix
    ./nvim/git.nix
    ./nvim/files.nix
    ./nvim/editing.nix
    ./nvim/dap.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      ripgrep
      fd
      git
      nodejs
      python3
      stylua
      alejandra
      shfmt
      prettierd
      black
      isort
      lua-language-server
      nil
    ];
  };
}
