{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Desktop
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.desktopConfiguration
      inputs.agenix.nixosModules.default
      inputs.hjem.nixosModules.default
    ];
  };
}
