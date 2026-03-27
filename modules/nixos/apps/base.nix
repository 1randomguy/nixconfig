{
  flake.nixosModules.base-apps = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      # web
      firefox
      chromium
      # organization
      geary
      evolution
      # image viewing, basic editing
      gthumb
      vlc
      # document viewing/editing
      libreoffice
      pdfarranger
      sioyek
      zotero
      kdePackages.okular
      # tasks
      taskwarrior3
      # tools
      nextcloud-client
      resources
      file-roller
      bluetui
      gitg
    ];
  };
}
