{pkgs, ...}:

{
  home.packages = with pkgs; [
    todoist-electron
    libreoffice
    pdfarranger
    anki
    nextcloud-client
    obsidian
    blanket
    texlive.combined.scheme-full
    texworks
    zathura
    openconnect
    networkmanager-openconnect
    networkmanagerapplet
  ];
}
