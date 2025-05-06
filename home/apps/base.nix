{pkgs, inputs, ...}:
### Apps that I will want to install on every desktop system
{
  home.packages = with pkgs; [
    # web
    firefox
    brave
    inputs.zen-browser.packages.${pkgs.system}.default
    # music listening
    spotify
    # image viewing, basic editing
    gthumb
    # document editing
    libreoffice
    pdfarranger
    # studying
    anki
    antimicrox
  ];
}
