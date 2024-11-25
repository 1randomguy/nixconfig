{...}:

{
  dconf.settings = {
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "spotify.desktop"
        "org.gnome.Nautilus.desktop"
        "obsidian.desktop"
        "anki.desktop"
        "signal-desktop.desktop"
        "discord.desktop"
        "kitty.desktop"
      ];
    };
    "org/gnome/desktop/background" = {
        "picture-uri" = "/home/bene/.dotfiles/assets/wallpapers/XE038441.jpg";
    };
  };
}
