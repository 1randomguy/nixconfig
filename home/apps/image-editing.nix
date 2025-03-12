{pkgs, ...}:

{
  home.packages = with pkgs; [
    ansel
    gimp
    inkscape
  ];
}
