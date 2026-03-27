{
  description = "locker flockig";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs.url = "/home/bene/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    nvim-plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    gd-tools.url = "github:1randomguy/gd-tools-flake";
    ashell.url = "github:MalpenZibo/ashell";
  };

  # outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
  outputs = inputs: 
  let
    myNixpkgsConfig = {
      allowUnfree = true;
      permittedInsecurePackages = [
        #"libsoup-2.74.3"
      ];
    };
  in
  inputs.flake-parts.lib.mkFlake { inherit inputs; } 
  {
    systems = [ "x86_64-linux" ]; # add "aarch64-linux" etc if needed
    _module.args.sharedNixpkgsConfig = {
      nixpkgs.config = myNixpkgsConfig;
    };
    imports = [
      (inputs.import-tree ./modules)
    ];
    perSystem = { system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = myNixpkgsConfig;
      };
    };
  };

  # outputs =
  #   inputs@{
  #     self,
  #     nixpkgs,
  #     wrappers,
  #     home-manager,
  #     disko,
  #     agenix,
  #     lanzaboote,
  #     ...
  #   }:
  #   let
  #     system = "x86_64-linux";
  #     pkgs = import nixpkgs {
  #       inherit system;
  #       config.allowUnfree = true;
  #       config.permittedInsecurePackages = [
  #         #"libsoup-2.74.3"
  #       ];
  #     };
  #     forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
  #     nvimModule = nixpkgs.lib.modules.importApply ./modules/neovim/module.nix inputs;
  #     nvimWrapper = wrappers.lib.evalModule nvimModule;
  #   in
  #   {
  #     # This exposes the standalone package for `nix run .#nvim-test`
  #     packages = forAllSystems (
  #       system:
  #       let
  #         pkgs = import nixpkgs { inherit system; };
  #       in
  #       {
  #         neovim = nvimWrapper.config.wrap { inherit pkgs; };
  #       }
  #     );
  #
  #     # This creates a NixOS module
  #     nixosModules.neovim = wrappers.lib.mkInstallModule {
  #       name = "neovim"; # When you use this, the option will be `wrappers.neovim.enable = true`
  #       value = nvimModule;
  #     };
  #     # This creates a Home Manager module
  #     homeManagerModules.neovim = wrappers.lib.mkInstallModule {
  #       name = "neovim"; # The option will be: wrappers.neovim.enable = true;
  #       # just import in the home.nix and then enable, no need to modify the modules in here:
  #       # imports = [
  #       #   self.homeManagerModules.neovim
  #       # ];
  #       value = nvimModule;
  #       path = [
  #         "home"
  #         "packages"
  #       ];
  #     };
  #
  #     # Dell Inspiron 13
  #     nixosConfigurations.inspiron13 = nixpkgs.lib.nixosSystem {
  #       specialArgs = {
  #         inherit system inputs;
  #       };
  #       modules = [
  #         {
  #           imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
  #           nixpkgs.pkgs = pkgs;
  #         }
  #         ./hosts/inspiron13/configuration.nix
  #         agenix.nixosModules.default
  #         home-manager.nixosModules.home-manager
  #         {
  #           home-manager.extraSpecialArgs = { inherit inputs; };
  #           home-manager.useGlobalPkgs = true;
  #           home-manager.useUserPackages = true;
  #           home-manager.users.bene = import ./hosts/inspiron13/home.nix;
  #         }
  #       ];
  #     };
  #     # Desktop
  #     nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
  #       specialArgs = {
  #         inherit system inputs;
  #       };
  #       modules = [
  #         {
  #           imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
  #           nixpkgs.pkgs = pkgs;
  #         }
  #         ./hosts/desktop/configuration.nix
  #         agenix.nixosModules.default
  #         home-manager.nixosModules.home-manager
  #         {
  #           home-manager.extraSpecialArgs = { inherit inputs; };
  #           home-manager.useGlobalPkgs = true;
  #           home-manager.useUserPackages = true;
  #           home-manager.users.bene = import ./hosts/desktop/home.nix;
  #         }
  #       ];
  #     };
  #     # Main Homeserver
  #     nixosConfigurations.usopp = nixpkgs.lib.nixosSystem {
  #       specialArgs = {
  #         inherit system inputs;
  #       };
  #       modules = [
  #         {
  #           imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
  #           nixpkgs.pkgs = pkgs;
  #         }
  #         ./hosts/usopp/configuration.nix
  #         disko.nixosModules.disko
  #         agenix.nixosModules.default
  #         home-manager.nixosModules.home-manager
  #         {
  #           home-manager.extraSpecialArgs = { inherit inputs; };
  #           home-manager.useGlobalPkgs = true;
  #           home-manager.useUserPackages = true;
  #           home-manager.users.bene = import ./hosts/usopp/home.nix;
  #         }
  #       ];
  #     };
  #     # Work Laptop
  #     nixosConfigurations.worklaptop = nixpkgs.lib.nixosSystem {
  #       specialArgs = {
  #         inherit system inputs;
  #       };
  #       modules = [
  #         {
  #           imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
  #           nixpkgs.pkgs = pkgs;
  #         }
  #         ./hosts/work-laptop/configuration.nix
  #         self.nixosModules.neovim
  #         agenix.nixosModules.default
  #         home-manager.nixosModules.home-manager
  #         {
  #           home-manager.extraSpecialArgs = { inherit inputs; };
  #           home-manager.useGlobalPkgs = true;
  #           home-manager.useUserPackages = true;
  #           home-manager.users.bene = import ./hosts/work-laptop/home.nix;
  #         }
  #       ];
  #     };
  #     # WSL
  #     homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
  #       inherit pkgs;
  #       extraSpecialArgs = { inherit inputs; };
  #       modules = [ ./hosts/wsl/home.nix ];
  #     };
  #     # WSL-work
  #     homeConfigurations.bene = home-manager.lib.homeManagerConfiguration {
  #       inherit pkgs;
  #       extraSpecialArgs = { inherit inputs; };
  #       modules = [ ./hosts/wsl-work/home.nix ];
  #     };
  #   };
}
