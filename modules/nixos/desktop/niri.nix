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
      pw-viz #?
      easyeffects #here?
    ];
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
    # SwayIdle
    systemd.user.services.swayidle = {
      description = "Idle manager for Wayland";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ "niri.service" ];
      serviceConfig = {
        Type = "simple";
        Environment = "PATH=${lib.makeBinPath [ pkgs.bash ]}";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            lock '${selfpkgs.hyprlock}/bin/hyprlock' \
            before-sleep 'loginctl lock-session'
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
  };
}
