{

  description = "Flake No.1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:1randomguy/nixvim";
    #nixvim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
    nixosConfigurations = {
      nixosX220 = lib.nixosSystem {
        specialArgs = {
	  inherit system inputs;
	};
	modules = [ 
	  ./configuration.nix
	  #{
          #  environment.systemPackages = [
	  #    inputs.nixvim.packages.${system}.default
          #  ];
	  #}
	];
      };
    };
    homeConfigurations = {
      bene = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };

}
