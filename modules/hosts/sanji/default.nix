{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Lenovo Thinkpad X9 15 "sanji"
  flake.nixosConfigurations.sanji = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.sanjiConfiguration
      inputs.agenix.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.hjem.nixosModules.default
    ];
  };
}
