{pkgs, ...}:

{
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.firejail.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 45d";
  };
  nix.optimise.automatic = true;
}
