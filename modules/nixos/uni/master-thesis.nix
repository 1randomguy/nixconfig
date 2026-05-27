{
  flake.nixosModules.master-thesis =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vscodium
      ];
      users.groups.chipwhisperer = { };
      users.users."bene".extraGroups = [
        "chipwhisperer"
        "dialout"
      ];
      services.udev.extraRules = ''
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", MODE="0664", GROUP="chipwhisperer"
        SUBSYSTEM=="tty", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", MODE="0664", GROUP="chipwhisperer", SYMLINK+="cw_serial%n"
        SUBSYSTEM=="tty", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", MODE="0664", GROUP="chipwhisperer", SYMLINK+="cw_bootloader%n"
      '';
    };
}
