{pkgs, ...}:

{
  users.users.bene.packages = with pkgs; [
    discord
    signal-desktop
  ];
}
