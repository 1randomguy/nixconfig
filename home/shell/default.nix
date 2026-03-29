{ lib, config, inputs, pkgs, ... }:
with lib;
let
  cfg = config.shell;
in {
  imports = [
    ./tmux
    ./zsh
    ./ghostty
  ];

  ## OPTIONS
  options.shell = {
    #enable = mkEnableOption "all about that shell";
    shelltools = mkOption {
      type = types.bool;
      default = true;
      description = "Shell Tools for making the shell useful";
    };
    nixos = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable some keyboard shortcuts that only seem to work inside of nixos, not in wsl";
    };
    remote = mkOption {
      type = types.bool;
      default = false;
      description = "System only accessed remotely via ssh";
    };
  };

  config = mkIf cfg.shelltools {
    home.packages = with pkgs; [
      #busybox
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
      direnv
      lazygit
    ];

    programs.git = {
      enable = true;
      settings = {
        user.name = "Benedikt von Blomberg";
        user.email = "bblomberg123@gmail.com";
        init.defaultBranch = "main";
        credential.helper = [
          "cache --timeout 21600"
          (mkIf (!cfg.remote) "oauth")
        ];
        pull.rebase = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
    };
  };
}
