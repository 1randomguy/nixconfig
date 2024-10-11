{pkgs, ...}:

{
  users.users.bene.packages = with pkgs; [
    rnote
    xournalpp
  ];
}
