{ self, ... }:
{
  flake.nixosModules.base-apps =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        selfpkgs.ghostty
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
        spotify
        fooyin
        lollypop
        easyeffects
        # document viewing/editing
        libreoffice
        pdfarranger
        sioyek
        zotero
        kdePackages.okular
        # tasks
        taskwarrior3
        logseq
        # tools
        nextcloud-client
        resources
        file-roller
        bluetui
        gitg
      ];
    };
}
