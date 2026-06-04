{ self, ... }:
{
  flake.nixosModules.shell = {pkgs, ...}:
  let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in
  {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      selfpkgs.neovim
      toybox
      git
      git-credential-oauth
      just
      fastfetch
      htop
      nix-prefetch-scripts
      fzf
      mosh
      zoxide
      gemini-cli
      rename
      devenv
      exiftool
      ripgrep
      dig
      gh
      lazygit
    ];
    programs.zoxide.enable = true;
    programs.yazi.enable = true;

    programs.direnv = {
      enable = true;
      settings = {
        global = {
          hide_env_diff = true;
        };
      };
    };

    programs.tmux = {
      enable = true;
      historyLimit = 5000;
      shortcut = "b";
      terminal = "tmux-256color";
      extraConfig = ''
        set -as terminal-overrides ",xterm*:Tc"

        set -gq allow-passthrough on
        set -g visual-activity off

        set -g mouse on
      '';
    };
  };
}
