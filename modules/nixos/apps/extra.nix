{inputs, ...}:
{
  flake.nixosModules.extra = {pkgs, ...}:
  {
    # these are extra apps for private machines
    environment.systemPackages = with pkgs; [
      # study
      anki
      goldendict-ng
      inputs.gd-tools.packages.${stdenv.hostPlatform.system}.default
      antimicrox
      # social
      vesktop
      (signal-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
        withAppleEmojis = true;
      })
      # other
      ausweisapp
      foliate
      protonvpn-gui
      typst
    ];
  };
}
