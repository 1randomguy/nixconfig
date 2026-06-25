{ self, inputs, ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;

      environment.systemPackages = [
        selfpkgs.neovim
        selfpkgs.zsh
        pkgs.toybox
        pkgs.git
        pkgs.git-credential-oauth
        pkgs.just
        pkgs.fastfetch
        pkgs.htop
        pkgs.nix-prefetch-scripts
        pkgs.fzf
        pkgs.mosh
        pkgs.zoxide
        pkgs.gemini-cli
        pkgs-unstable.antigravity-cli
        pkgs.rename
        pkgs.devenv
        pkgs.exiftool
        pkgs.ripgrep
        pkgs.dig
        pkgs.gh
        pkgs.lazygit
      ];
      programs.zoxide.enable = true;
      programs.yazi.enable = true;

      programs.git = {
        enable = true;
        config = {
          user.name = "Benedikt von Blomberg";
          user.email = "bblomberg123@gmail.com";
          init.defaultBranch = "main";
          credential.helper = [
            "cache --timeout 21600"
            "oauth"
          ];
          pull.rebase = true;
        };
      };

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
