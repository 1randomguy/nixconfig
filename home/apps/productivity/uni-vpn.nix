{pkgs, ...}:

{
  home.packages = with pkgs; [
    openconnect
    networkmanager-openconnect
    networkmanagerapplet
  ];
}
