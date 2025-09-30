{
  description = "Joshua's Home Manager only config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kickstart = {
	url = "github:jdtaylor311/kickstart.nvim";
			flake = false;
	};
  };

  outputs = { self, nixpkgs, home-manager, kickstart, ... }:
let supportedSystems = [ "aarch64-darwin" "x84_64-linux" ];
forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
 in {
	homeConfigurations = {
      "jdtaylor311-darwin" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; }; # or x86_64-linux
          modules = [ 
	    {
		home.file.".config/nvim".source = kickstart;
            }
	    ./home.nix 
	  ];
        };
      "jdtaylor311-linux" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; }; # or x86_64-linux
          modules = [ 
	    {
		home.file.".config/nvim".source = kickstart;
            }
	    ./home.nix 
	  ];
        };
	};
    };
}
