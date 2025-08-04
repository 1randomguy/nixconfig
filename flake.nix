{
  description = "locker flockig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs.url = "/home/bene/nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:1randomguy/nixvim";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, disko, agenix, ... }:
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
      # Thinkpad X220
      nixosConfigurations.nixosX220 = lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
        };
        modules = [
          { 
          imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
          nixpkgs.pkgs = pkgs; 
          }
          ./hosts/x220/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bene = import ./hosts/x220/home.nix;
          }
        ];
      };
      # Dell Inspiron 13
      nixosConfigurations.inspiron13 = lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
        };
        modules = [
          { 
          imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
          nixpkgs.pkgs = pkgs; 
          }
          ./hosts/inspiron13/configuration.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bene = import ./hosts/inspiron13/home.nix;
          }
        ];
      };
      # Desktop
      nixosConfigurations.desktop = lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
        };
        modules = [
          { 
          imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
          nixpkgs.pkgs = pkgs; 
          }
          ./hosts/desktop/configuration.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bene = import ./hosts/desktop/home.nix;
          }
        ];
      };
      # Main Homeserver
      nixosConfigurations.usopp = lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
        };
        modules = [
          { 
          imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
          nixpkgs.pkgs = pkgs; 
          }
          ./hosts/usopp/configuration.nix
          disko.nixosModules.disko
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bene = import ./hosts/usopp/home.nix;
          }
        ];
      };
      # Work Laptop
      nixosConfigurations.worklaptop = lib.nixosSystem {
        specialArgs = {
          inherit system inputs;
        };
        modules = [
          { 
          imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
          nixpkgs.pkgs = pkgs; 
          }
          ./hosts/work-laptop/configuration.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bene = import ./hosts/work-laptop/home.nix;
          }
        ];
      };
      # WSL
      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/wsl/home.nix ];
      };
      # WSL-work
      homeConfigurations.bene = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/wsl-work/home.nix ];
      };
    };
}
