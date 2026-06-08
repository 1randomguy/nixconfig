{
  flake.nixosModules.razer = { pkgs, ... }: {
    hardware.openrazer.enable = true;
    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];
    users.users.bene.extraGroups = [ "openrazer" ];
  };
}
