{
  description = "Jdtaylor311's Home Manager ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    # Correct supported systems (typo fixed: x84_64-linux -> x86_64-linux)
    supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    ##########################################################################
    # Home Manager configurations
    ##########################################################################
    homeConfigurations = {
      "jdtaylor311-darwin" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
        modules = [ ./home.nix ./modules/neovim.nix ];
      };
      "jdtaylor311-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [ ./home.nix ./modules/neovim.nix ];
      };
    };

    ##########################################################################
    # Convenience packages & apps to switch from ANY directory
    # Usage examples after building:
    #   nix run path:/path/to/nix-config#hm-switch-darwin
    #   nix run github:jdtaylor311/nix-config#hm-switch-linux
    # Or install permanently:
    #   nix profile install path:/path/to/nix-config#hm-switch-darwin
    ##########################################################################
    packages = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
      hm = home-manager.packages.${system}.home-manager;
    in {
      hm-switch-darwin = pkgs.writeShellScriptBin "hm-switch-darwin" ''
        exec ${hm}/bin/home-manager switch --flake ${self}#jdtaylor311-darwin "$@"
      '';
      hm-switch-linux = pkgs.writeShellScriptBin "hm-switch-linux" ''
        exec ${hm}/bin/home-manager switch --flake ${self}#jdtaylor311-linux "$@"
      '';
    });

    # Provide runnable apps so you can `nix run` directly.
    apps = forAllSystems (system: {
      hm-switch-darwin = {
        type = "app";
        program = "${self.packages.${system}.hm-switch-darwin}/bin/hm-switch-darwin";
      };
      hm-switch-linux = {
        type = "app";
        program = "${self.packages.${system}.hm-switch-linux}/bin/hm-switch-linux";
      };
    });
  };
}
