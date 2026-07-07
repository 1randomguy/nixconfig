{ self, inputs, ... }:
{
  flake.nixosModules.base-apps =
    { pkgs, ... }:
    {
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
        spotify
        # fooyin
        inputs.fooyin-pr.legacyPackages.${pkgs.stdenv.hostPlatform.system}.fooyin
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
        localsend
      ];
      hjem.users.bene.files.".config/ghostty".source = ./config/ghostty;
    };
}
