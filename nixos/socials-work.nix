{pkgs, ...}:

{
  users.users.bene.packages = with pkgs; [
    zoom-us
    teams-for-linux
  ];
}
