{pkgs, ...}:

{
  #Extensions:
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
  ];

  xdg.desktopEntries.kitty = {
    type = "Application";
    name = "kitty";
    genericName = "Terminal emulator";
    exec = "kitty";
    categories = [ "System" "TerminalEmulator" ];
    icon = "/home/bene/nixconfig/assets/icons/whiskers.svg";
    startupNotify = true;
    comment = "Fast, feature-rich, GPU based terminal";
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-fullscreen = ["F11"];
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = ["<Shift><Super>s"];
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
      clock-show-weekday = true;
    };

    "org/gnome/desktop/background" = {
        "picture-uri" = "/home/bene/nixconfig/assets/wallpapers/594530.jpg";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "zen.desktop"
        "kitty.desktop"
        "org.gnome.Nautilus.desktop"
        "anki.desktop"
        "spotify.desktop"
        "signal-desktop.desktop"
        "discord.desktop"
      ];
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        pkgs.gnomeExtensions.blur-my-shell.extensionUuid
      ];
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };

  };
}
