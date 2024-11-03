{pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    ansel
    gimp
    inkscape
  ];
}
