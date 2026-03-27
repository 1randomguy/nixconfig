{
  flake.nixosModules.socials = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      discord
      (signal-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
        withAppleEmojis = true;
      })
    ];
  };
}
