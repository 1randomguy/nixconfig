{ lib, config, pkgs, ... }: 
let
  cfg = config.desktop.niri;
in
{
  options.desktop.niri = {
    enable = lib.mkEnableOption "enable Niri desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/niri/config.kdl" = { source = ./config.kdl; };
    home.packages = with pkgs; [ 
      xwayland-satellite 
      xwayland-run 
      cage 
      brightnessctl 
      swaylock
      fuzzel
      kanshi
      phinger-cursors
    ];

    home.pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      gtk.enable = true;
      x11.enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = config.home.pointerCursor.name;
        cursor-size = config.home.pointerCursor.size;
      };
    };

    home.file.".config/kanshi/config".text = ''
      output "LG Electronics LG IPS FULLHD 0x00044374" {
        mode 1920x1080@60.000
        position 0,0
        scale 1
        alias $HOME_1
      }
      output "Dell Inc. DELL P2419HC 2LCLK03" {
        mode 1920x1080@60.000
        position 1920,0
        scale 1
        alias $HOME_2
      }
      output "AU Optronics 0x252B Unknown" {
        mode 3840x2160@60.000
        position 0,0
        scale 2
        alias $INSPI_INTERNAL
      }
      output "AU Optronics 0x4B98 Unknown" {
        mode 1920x1200@60.000
        position 3840,0
        scale 1
        alias $WORK_INTERNAL
      }
      output "Lenovo Group Limited L32p-30 U5127VZD" {
        mode 3840x2160@60.000
        position 0,0
        scale 1.5
        alias $WORK_EXTERNAL
      }

      profile inspi_undocked {
        output $INSPI_INTERNAL enable
      }
      profile inspi_docked {
        output $INSPI_INTERNAL disable
        output $HOME_1 enable
        output $HOME_2 enable
      }
      profile home_1 {
        output $HOME_1 enable
        output $HOME_2 enable
      }
      profile work_office {
        output $WORK_EXTERNAL enable
        output $WORK_INTERNAL enable
      }
      profile work_mobile {
        output $WORK_INTERNAL enable
      }
      profile work_home {
        output $WORK_INTERNAL disable
        output $HOME_1 enable
        output $HOME_2 enable
      }
    '';
  };
}
