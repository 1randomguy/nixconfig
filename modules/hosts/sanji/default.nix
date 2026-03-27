{ self, inputs, ... }:
{
  # Lenovo Thinkpad X9 15 "sanji"
  flake.nixosConfigurations.sanji = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # {
      #   imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
      #   nixpkgs.pkgs = pkgs;
      # }
      self.nixosModules.sanjiConfiguration
      #self.nixosModules.neovim
      # And then put `wrappers.nvim-test.enable = true;` in your configuration.nix
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
