{ self, inputs, ... }:
{
  flake.nixosModules.base-apps =
    { pkgs, ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      services.flatpak = {
        enable = true;
        packages = [
          "com.yubico.yubioath"
          "io.github.tanaybhomia.DeepDive"
          "com.github.tchx84.Flatseal"
          "com.spotify.Client"
          "org.libreoffice.LibreOffice"
          "org.zotero.Zotero"
          "com.logseq.Logseq"
          "org.fooyin.fooyin"
          "org.gnome.Epiphany"
          "io.github.CyberTimon.RapidRAW"
        ];
      };

      environment.systemPackages = with pkgs; [
        ghostty
        wl-clipboard
        # web
        firefox
        chromium
        # organization
        geary
        evolution
        # image viewing, basic editing
        gthumb
        vlc
        # music
        amberol
        easyeffects
        # document viewing/editing
        pdfarranger
        kdePackages.okular
        pympress
        # tasks
        taskwarrior3
        # tools
        nextcloud-client
        resources
        file-roller
        bluetui
        gitg
        localsend
      ];
      hjem.users.bene.files.".config/ghostty".source = ./config/ghostty;
      hjem.users.bene.files.".config/fooyin".source = ./config/fooyin;
    };
}
