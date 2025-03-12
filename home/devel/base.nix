{pkgs, ...}:

{
  home.packages = with pkgs; [
    gitg
  ];
}
