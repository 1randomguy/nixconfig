{ lib, config, inputs, pkgs, ... }:
with lib;
let
  cfg = config.shell;
in {
  imports = [
    ./tmux
    ./zsh
    ./ghostty
    ./zk
    ./nvf
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
      git
      git-credential-oauth
      inputs.nixvim.packages.${system}.default
      just
      wget
      neofetch
      htop
      file
      nix-prefetch-scripts
      fzf
      mosh
    ];

    programs.git = {
      enable = true;
      userName = "Benedikt von Blomberg";
      userEmail = "github@bvb.anonaddy.com";
      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = [
          "cache --timeout 21600"
          (mkIf (!cfg.remote) "oauth")
        ];
        pull.rebase = true;
      };
    };

    programs.yazi = {
      enable = true;
    };
  };
}
