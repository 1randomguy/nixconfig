{ self, inputs, sharedNixpkgsConfig, ... }:
{
  # Desktop
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      sharedNixpkgsConfig
      self.nixosModules.desktopConfiguration
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.bene = import ../../../home/hosts/desktop.nix;
      }
    ];
  };
}
