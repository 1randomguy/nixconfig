{pkgs, ...}:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "de";
    xkb.options = "eurosign:e,caps:escape";
    excludePackages = with pkgs; [
      xterm
    ];
  };
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    gnome-characters
    gnome-font-viewer
    simple-scan
    yelp # help viewer
    gnome-weather
    gnome-maps
    gnome-contacts
  ];
  programs.dconf.enable = true;
}
