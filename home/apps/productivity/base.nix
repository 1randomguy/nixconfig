{pkgs, ...}:

{
  home.packages = with pkgs; [
    libreoffice
    pdfarranger
    anki
    blanket
  ];
}
