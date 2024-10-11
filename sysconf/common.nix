{pkgs, inputs, ...}:

{
  environment.systemPackages = with pkgs; [
    git
    gitg
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    neofetch
    wget
    alacritty
  ];
  users.users.bene.packages = with pkgs; [
    spotify
    firefox
  ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
