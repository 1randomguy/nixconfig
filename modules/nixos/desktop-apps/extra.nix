{inputs, ...}:
{
  flake.nixosModules.extra-apps = {pkgs, ...}:
  {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak.packages = [
      "dev.vencord.Vesktop"
      "de.bund.ausweisapp.ausweisapp2"
    ];

    # these are extra apps for private machines
    environment.systemPackages = with pkgs; [
      # study
      anki
      goldendict-ng
      inputs.gd-tools.packages.${stdenv.hostPlatform.system}.default
      antimicrox
      # social
      (signal-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
        withAppleEmojis = true;
      })
      cinny-desktop
      # music
      spek
      soundconverter
      yt-dlp
      parabolic
      # other
      foliate
      proton-vpn
      typst
      obs-studio
      # shell tools
      android-tools
    ];
  };
}
