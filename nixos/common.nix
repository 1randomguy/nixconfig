{pkgs, ...}:

{
  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 45d";
  };
  nix.optimise.automatic = true;
}
