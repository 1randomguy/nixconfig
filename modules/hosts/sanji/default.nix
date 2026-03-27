{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Lenovo Thinkpad X9 15 "sanji"
  flake.nixosConfigurations.sanji = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.sanjiConfiguration
      inputs.agenix.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.bene = import ../../../home/hosts/sanji.nix;
      }
    ];
  };
}
