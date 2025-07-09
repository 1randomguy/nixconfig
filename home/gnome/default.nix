{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.gnome_customizations;
in {
  options.gnome_customizations = {
    enable = mkEnableOption "Toggle my custom gnome options";
    wallpaper = mkOption {
      type = types.str;
      default = "file:///run/current-system/sw/share/backgrounds/gnome/amber-l.jx";
      description = "Path to the picture that you want to use as a wallpaper";
    };
  };

  config = mkIf cfg.enable {
    #Extensions:
    home.packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      pip-on-top
      gsconnect
      caffeine
    ];

    dconf.settings = {
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
        workspaces-only-on-primary = false;
      };

      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        show-battery-percentage = true;
        clock-show-weekday = true;
      };

      "org/gnome/desktop/background" = {
        "picture-uri" = cfg.wallpaper;
        "picture-uri-dark" = cfg.wallpaper;
      };
      "org/gnome/desktop/screensaver" = {
        "picture-uri" = cfg.wallpaper;
      };

      "org/gnome/shell" = {
        favorite-apps = [
            "zen.desktop"
            "com.mitchellh.ghostty.desktop"
            "org.gnome.Nautilus.desktop"
            "anki.desktop"
            "spotify.desktop"
            "signal.desktop"
            "discord.desktop"
        ];
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          pip-on-top.extensionUuid
          gsconnect.extensionUuid
          caffeine.extensionUuid
        ];
      };

      "org/gnome/shell/extensions/blur-my-shell/panel" = {
        blur = false;
      };

    };
  };
}
