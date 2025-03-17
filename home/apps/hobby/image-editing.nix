{pkgs, ...}:

{
  home.packages = with pkgs; [
    ansel
    darktable
    gimp
    inkscape
  ];
}
