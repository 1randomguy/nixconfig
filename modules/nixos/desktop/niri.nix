{self, ...}:
{
  flake.nixosModules.niri = {pkgs, lib, ...}:
  let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in
  {
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      xwayland-run
      cage
      brightnessctl
      swaybg
      phinger-cursors

      nirius # if we embed it in the command config of niri we might not need it as a systempackage here?
      # helpful tuis
      wifitui #?
      # helpful guis
      waypaper
      wdisplays
      gnome-online-accounts-gtk
      networkmanagerapplet
      #blueman #?
      pwvucontrol
      walker

      (pkgs.writeShellScriptBin "nw" ''
        if [ -n "$1" ]; then
          if WORKSPACES=$(niri msg --json workspaces 2>/dev/null); then
            if echo "$WORKSPACES" | ${pkgs.jq}/bin/jq -e --arg name "$1" '.[] | select(.name == $name)' >/dev/null; then
              exec niri msg action focus-workspace "$1"
            fi
          fi
          exec niri msg action set-workspace-name "$1"
        else
          exec niri msg action unset-workspace-name
        fi
      '')
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
    systemd.user.services.elephant = {
      path = [
        pkgs.bash
        "/run/current-system/sw"      # System-wide packages
        "/etc/profiles/per-user/%u"   # User-specific packages (%u is systemd's variable for your username)
      ];
    };
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
    # Kanshi
    systemd.user.services.kanshi = {
      description = "Kanshi Automatic Monitor Setup";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "niri.service" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = ''${lib.getExe selfpkgs.kanshi}'';
          Restart = "always";
          RestartSec = 1;
      };
    };
  };
}
