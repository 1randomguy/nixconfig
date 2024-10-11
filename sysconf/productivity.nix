{pkgs, ...}:

{
  users.users.bene.packages = with pkgs; [
    logseq
    todoist-electron
    libreoffice
  ];
}
