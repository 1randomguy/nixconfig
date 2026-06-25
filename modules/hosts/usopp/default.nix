{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Main Homeserver "usopp"
  flake.nixosConfigurations.usopp = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.usoppConfiguration
      inputs.agenix.nixosModules.default
    ];
  };
}
