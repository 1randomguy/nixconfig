{inputs, ...}:
{
  flake.nixosModules.extra-apps = {pkgs, ...}:
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
      # music
      spek
      soundconverter
      # other
      ausweisapp
      foliate
      proton-vpn
      typst
    ];
  };
}
