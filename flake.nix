{
  description = "locker flockig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:1randomguy/nixvim";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "electron-27.3.11"
        ];
      };
    in {
      nixosConfigurations = {
        nixosX220 = lib.nixosSystem {
          specialArgs = {
            inherit system inputs pkgs;
          };
          modules = [ ./sysconf/x220/configuration.nix ];
        };
        inspiron13 = lib.nixosSystem {
          specialArgs = {
            inherit system inputs pkgs;
          };
          modules = [ ./sysconf/inspiron13/configuration.nix ];
        };
      };
      homeConfigurations = {
        bene = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./homeconf/home.nix ];
        };
      };
    };
}
