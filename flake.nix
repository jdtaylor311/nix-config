{
  description = "Jdtaylor311's Home Manager ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    supportedSystems = ["aarch64-darwin" "x84_64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    homeConfigurations = {
      "jdtaylor311-darwin" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "aarch64-darwin";};
        modules = [
          ./home.nix
          ./modules/neovim.nix
        ];
      };
      "jdtaylor311-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "aarch64-darwin";};
        modules = [
          ./home.nix
          ./modules/neovim.nix
        ];
      };
    };
  };
}
