{pkgs, ...}:

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
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 45d";
  };
  nix.optimise.automatic = true;
}
