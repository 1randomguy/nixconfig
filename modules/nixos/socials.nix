{
  flake.nixosModules.socials = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      vesktop
      (signal-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
        withAppleEmojis = true;
      })
    ];
  };
}
