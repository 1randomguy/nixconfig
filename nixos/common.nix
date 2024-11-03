{pkgs, inputs, ...}:

{
  environment.systemPackages = with pkgs; [
    kitty
    gitg
  ];
  users.users.bene.packages = with pkgs; [
    spotify
    firefox
  ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
