{ self, ... }:
{
  flake.nixosModules.shell = {pkgs, ...}:
  let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
  in
  {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    environment.systemPackages = [
      selfpkgs.neovim
    ];


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
