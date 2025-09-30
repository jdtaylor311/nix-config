{ config, pkgs, lib, ... }:

let
  homeDir = if pkgs.stdenv.isDarwin then "/Users/jdtaylor311" else "/home/jdtaylor311";
in {
  home.username = "jdtaylor311";
  home.homeDirectory = homeDir;
  home.stateVersion = "25.05";

  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
    PATH = "$HOME/.local/bin:$PATH";
    SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
  };

  home.packages = import ./modules/common-packages.nix { inherit pkgs; };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
    # Source modular scripts
    if [ -d ~/.bashrc.d ]; then
      for f in ~/.bashrc.d/*; do
        [ -r "$f" ] && source "$f"
      done
    fi
  '';
  };

  programs.git = {
    enable = true;
    userName = "Joshua Taylor";
    userEmail = "jdtaylor311@outlook.com";
  };

  programs.fzf.enable = true;

  # Map bash files and directories
  home.file.".bashrc.d".source = ./home/bash/.bashrc.d;
}
