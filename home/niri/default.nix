{ pkgs, ... }: {
  home.file.".config/niri/config.kdl" = { source = ./config.kdl; };
  home.packages = with pkgs; [ 
    xwayland-satellite 
    xwayland-run 
    cage 
    squeekboard 
    brightnessctl 
    swaylock
    fuzzel
    waybar
  ];
}
