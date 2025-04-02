{pkgs, ...}:

{
  home.packages = with pkgs; [
    blanket
  ];
}
