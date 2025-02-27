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
    openconnect
    networkmanager-openconnect
    networkmanagerapplet
  ];
}
