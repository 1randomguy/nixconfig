{pkgs, ...}:

{
  users.users.bene.packages = with pkgs; [
    todoist-electron
    libreoffice
    pdfarranger
    anki
  ];
}
