{
  description = "Joshua's Home Manager only config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    {
      homeConfigurations."jdtaylor311" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; }; # or x86_64-linux
          modules = [ ./home.nix ];
        };
    };
}
