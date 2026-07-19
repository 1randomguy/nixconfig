{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # New Main Homeserver "chopper"
  flake.nixosConfigurations.chopper = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.chopperConfiguration
      inputs.agenix.nixosModules.default
    ];
  };
}
