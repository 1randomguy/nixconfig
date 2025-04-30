{pkgs, ...}:

{
  home.packages = with pkgs; [
    darktable
    gimp
    inkscape
  ];
}
