{pkgs, ...}:

{
  home.packages = with pkgs; [
    nodejs
    mongosh
  ];
}
