{
  flake.nixosModules.niri = {pkgs, lib, ...}:
  {
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
            lock '${pkgs.hyprlock}/bin/hyprlock' \
            before-sleep 'loginctl lock-session'
        '';
        #timeout 300 '${niriCmd "off"}' \
        Restart = "always";
      };
    };
  };
}
