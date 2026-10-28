{inputs, ...}:
{
  flake.nixosModules.extra-apps =
    {pkgs, ...}:
    let
      lyrics-to-lrc = pkgs.writeShellApplication {
        name = "lyrics-to-lrc";
        runtimeInputs = [ (pkgs.python3.withPackages (ps: [ ps.mutagen ])) ];
        text = ''
          exec python3 ${./scripts/lyrics-to-lrc.py} "$@"
        '';
      };
    in
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
        beets
        lyrics-to-lrc
        inputs.flint.packages.${stdenv.hostPlatform.system}.flint-gtk
        # other
        imagemagick
        gpodder
        foliate
        proton-vpn
        typst
        obs-studio
        # shell tools
        android-tools
      ];
    };
}
