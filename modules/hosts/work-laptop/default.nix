{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Work Laptop
  flake.nixosConfigurations.worklaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.worklaptopConfiguration
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.bene = import ../../../home/hosts/work.nix;
      }
    ];
  };
}
