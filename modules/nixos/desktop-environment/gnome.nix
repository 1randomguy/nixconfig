{self, ...}:
{
  flake.nixosModules.gnome = {pkgs, ...}:
  {
    # This forces GTK3/GTK4 apps (including flatpaks) to respect the cursor
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        # "org/gnome/desktop/interface" = {
        #   cursor-theme = "phinger-cursors-light";
        #   cursor-size = pkgs.lib.gvariant.mkInt32 32; 
        # };

        # "org/gnome/desktop/background" = {
        #   "picture-uri" = cfg.wallpaper;
        #   "picture-uri-dark" = cfg.wallpaper;
        # };
        # "org/gnome/desktop/screensaver" = {
        #   "picture-uri" = cfg.wallpaper;
        # };

        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Super>q"];
          toggle-fullscreen = ["F11"];
          move-to-workspace-left = ["<Shift><Alt>h"];
          move-to-workspace-right = ["<Shift><Alt>l"];
          switch-to-workspace-left = ["<Alt>h"];
          switch-to-workspace-right = ["<Alt>l"];
        };

        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = ["<Shift><Super>s"];
        };

        "org/gnome/mutter" = {
          edge-tiling = true;
          dynamic-workspaces = true;
          #workspaces-only-on-primary = false;
        };

        "org/gnome/desktop/interface" = {
          enable-hot-corners = false;
          show-battery-percentage = true;
          clock-show-weekday = true;
        };


        "org/gnome/shell" = {
          favorite-apps = [
              "firefox.desktop"
              "com.mitchellh.ghostty.desktop"
              "org.gnome.Nautilus.desktop"
              "anki.desktop"
              "spotify.desktop"
              "fooyin.desktop"
              "signal.desktop"
          ];
        };
      };
    }];
    services.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany
      gnome-characters
      gnome-font-viewer
      gnome-software
      simple-scan
      yelp # help viewer
      gnome-weather
      gnome-maps
      gnome-contacts
    ];
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };
}
