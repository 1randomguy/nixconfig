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
    icon = "../../assets/icons/whiskers.svg";
    startupNotify = true;
    comment = "Fast, feature-rich, GPU based terminal";
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      screenshot = ["<Shift><Super>s"];
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/background" = {
        "picture-uri" = "/home/bene/.dotfiles/assets/wallpapers/XE038441.jpg";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "spotify.desktop"
        "org.gnome.Nautilus.desktop"
        "kitty.desktop"
        "anki.desktop"
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
