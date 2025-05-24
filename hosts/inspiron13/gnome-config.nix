{pkgs, ...}:

{
  #Extensions:
  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
  ];

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
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
        "picture-uri" = "file:///home/bene/nixconfig/assets/wallpapers/XE038441.jpg";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "brave-browser.desktop"
        "com.mitchellh.ghostty.desktop"
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
