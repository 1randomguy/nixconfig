{pkgs, ...}:

{
  home.packages = with pkgs; [
    zoom-us
    teams-for-linux
  ];
}
