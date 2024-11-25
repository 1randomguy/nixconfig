{pkgs, ...}:

{
  home.packages = with pkgs; [
    logseq
    todoist-electron
    libreoffice
    pdfarranger
    anki
    nextcloud-client
    obsidian
  ];
}
