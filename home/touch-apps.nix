{pkgs, ...}:

{
  home.packages = with pkgs; [
    xournalpp
    rnote
  ];
}
