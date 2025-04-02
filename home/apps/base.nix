{pkgs, ...}:
### Apps that I will want to install on every desktop system
{
  home.packages = with pkgs; [
    # web
    firefox
    brave
    # music listening
    spotify
    # image viewing, basic editing
    gthumb
    # document editing
    libreoffice
    pdfarranger
    # studying
    anki
  ];
}
