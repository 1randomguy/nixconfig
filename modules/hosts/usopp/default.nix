{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Main Homeserver "usopp"
  flake.nixosConfigurations.usopp = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.usoppConfiguration
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.bene = import ../../../home/hosts/usopp.nix;
      }
    ];
  };
}
