{self, ...}:
{
  flake.nixosModules.niri = {pkgs, lib, ...}:
  let
    selfpkgs = self.packages."${pkgs.system}";
  in
  {
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      xwayland-run
      cage
      brightnessctl
      swaybg
      phinger-cursors

      kanshi # make into systemd service / replace by shikane?
      nirius # if we embed it in the command config of niri we might not need it as a systempackage here?
      # helpful tuis
      wifitui #?
      # helpful guis
      waypaper
      wdisplays
      gnome-online-accounts-gtk
      networkmanagerapplet
      blueman #?
      pwvucontrol
      walker
    ];
    programs.niri.enable = true;
    programs.niri.package = selfpkgs.niri;
    services.displayManager.defaultSession = "niri";
    # cursor
    environment.variables = {
      XCURSOR_THEME = "phinger-cursors-light";
      XCURSOR_SIZE = "32";
    };
    # This forces GTK3/GTK4 apps (including flatpaks) to respect the cursor
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          cursor-theme = "phinger-cursors-light";
          cursor-size = pkgs.lib.gvariant.mkInt32 32; 
        };
      };
    }];
    # This catches stubborn XWayland apps that ignore the environment variables
    environment.etc."X11/Xresources".text = ''
      Xcursor.theme: phinger-cursors-light
      Xcursor.size: 32
    '';
    # keyboard
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "altgr-intl";
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk      # GTK support
        #fcitx5-configtool # GUI for configuration
        qt6Packages.fcitx5-configtool
      ];
    };
    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      #GTK_IM_MODULE = "fcitx";
      #QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    environment.sessionVariables = {
      GI_TYPELIB_PATH = lib.makeSearchPath "lib/girepository-1.0" (
        with pkgs;
        [
          evolution-data-server
          libical
          glib.out
          libsoup_3
          json-glib
          gobject-introspection
        ]
      );
    };
    # Nirius
    systemd.user.services.niriusd = {
      description = "Nirius Daemon for Niri";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "niri.service" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.nirius}/bin/niriusd'';
          Restart = "always";
          RestartSec = 1;
      };
    };
    # SwayOSD
    systemd.user.services.swayosd = {
      description = "Volume/backlight OSD indicator";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      startLimitBurst = 5;
      startLimitIntervalSec = 10;
      wantedBy = [ "niri.service" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
          Restart = "always";
          RestartSec = 2;
      };
    };
    # Hyprlock
    programs.hyprlock.enable = true;
    programs.hyprlock.package = selfpkgs.hyprlock;
    services.hypridle.enable = lib.mkForce false;
    # SwayIdle
    systemd.user.services.swayidle = {
      description = "Idle manager for Wayland";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        Environment = "PATH=${lib.makeBinPath [ pkgs.bash pkgs.systemd ]}";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            before-sleep '${selfpkgs.hyprlockSmart}/bin/lock' \
            lock '${selfpkgs.hyprlockSmart}/bin/lock'
        '';
        #timeout 300 '${niriCmd "off"}' \
        Restart = "always";
      };
    };
    # Configure Wallpaper set in Waypaper as Hyperlock Background
    systemd.user.services.configure-waypaper = {
      description = "Initialize waypaper config with post_command";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      script = ''
        mkdir -p $HOME/.config/waypaper
        touch $HOME/.config/waypaper/config.ini
        if ! grep -q "^\[Settings\]" $HOME/.config/waypaper/config.ini; then
          echo "[Settings]" >> $HOME/.config/waypaper/config.ini
        fi
        # Use crudini to set post_command while keeping the file otherwise writable for waypaper
        ${pkgs.crudini}/bin/crudini --set $HOME/.config/waypaper/config.ini Settings post_command 'ln -sf "$wallpaper" $HOME/.cache/current_wallpaper'
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
    # Walker
    services.elephant.enable = true;
    systemd.user.services.walker = {
      description = "Walker - Application Runner";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" "elephant.service" ];
      requires = [ "elephant.service" ];
      wantedBy = [ "niri.service" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.walker} --gapplication-service";
        Environment = "PATH=${lib.makeBinPath [ pkgs.elephant ]}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
