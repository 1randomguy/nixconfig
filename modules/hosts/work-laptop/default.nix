{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Work Laptop
  flake.nixosConfigurations.worklaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.worklaptopConfiguration
      inputs.agenix.nixosModules.default
      inputs.hjem.nixosModules.default
    ];
  };
}
