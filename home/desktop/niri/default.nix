{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.desktop.niri;
in
{
  imports = [ inputs.walker.homeManagerModules.default ];

  options.desktop.niri = {
    enable = lib.mkEnableOption "enable Niri desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/niri/config.kdl" = {
      source = ./config.kdl;
    };
    home.packages = with pkgs; [
      xwayland-satellite
      xwayland-run
      cage
      brightnessctl
      kanshi
      phinger-cursors
      swayosd
      swaybg
      # helpful tuis
      wifitui
      # helpful guis
      wdisplays
      waypaper
      gnome-online-accounts-gtk
      networkmanagerapplet
      blueberry
      easyeffects
      pwvucontrol
      pw-viz
    ];

    home.pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      gtk.enable = true;
      x11.enable = true;
    };

    services.swayosd = {
      enable = true;
    };

    services.swayidle =
      let
        # Lock command
        lock = "${pkgs.hyprlock}/bin/hyprlock";
        # Niri
        display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
      in
      {
        enable = true;
        extraArgs = [ "-w" ];
        events = {
          before-sleep = (display "off") + "; " + lock;
          after-resume = display "on";
          lock = lock;
          unlock = display "on";
        };
      };

    programs.walker = {
      enable = true;
      runAsService = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = config.home.pointerCursor.name;
        cursor-size = config.home.pointerCursor.size;
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

        animations = {
          enabled = true;
          fade_in = {
            duration = 300;
            bezier = "easeOutQuint";
          };
          fade_out = {
            duration = 300;
            bezier = "easeOutQuint";
          };
        };

        auth = {
          "fingerprint:enabled" = true;
          "fingerprint:ready_message" = "(Scan fingerprint to unlock)";
          "fingerprint:present_message" = "Scanning fingerprint";
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 4;
            blur_size = 10;
            brightness = 0.5;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "15%, 5%";  # Responsive size (much larger)
            outline_thickness = 3;

            # Base (transparent)
            inner_color = "rgba(30, 30, 46, 0.0)"; 
            # Lavender -> Green (Default Gradient)
            outer_color = "rgb(b4befe) rgb(a6e3a1) 45deg";
            # Yellow -> Peach (Checking Password)
            check_color = "rgb(f9e2af) rgb(fab387) 120deg";
            # Red -> Maroon (Fail)
            fail_color = "rgb(f38ba8) rgb(eba0ac) 40deg";

            font_color = "rgb(143, 143, 143)";
            fade_on_empty = false;
            rounding = 15;

            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];
        label = [
          {
            text = "$TIME";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 128;
            font_family = "Adwaita Sans";
            position = "0, 160";
            halign = "center";
            valign = "center";
          }
          {
            text = "$FPRINTPROMPT";
            color = "rgb(202, 211, 245)";
            font_size = 14;
            font_family = "Adwaita Sans"; 
            position = "0, -100";  # Placed below the input field
            halign = "center";
            valign = "center";
          }
        ];
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
      output "Samsung Display Corp. ATNA53JB01-0  Unknown" {
        mode 2880x1800@60.000
        position 0,0
        scale 2
        alias $SANJI_INTERNAL
      }
      output "AU Optronics 0x4B98 Unknown" {
        mode 1920x1200@60.000
        position 2560,240
        scale 1
        alias $WORK_INTERNAL
      }
      output "Lenovo Group Limited L32p-30 U5127VZD" {
        mode 3840x2160@60.000
        position 0,0
        scale 1.5
        alias $WORK_EXTERNAL
      }

      profile sanji_undocked {
        output $SANJI_INTERNAL enable
      }
      profile sanji_docked {
        output $SANJI_INTERNAL disable
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
