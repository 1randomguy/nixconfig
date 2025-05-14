{ lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    git
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    neofetch
    wget
    zk
    fzf
    just
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    #historyLimit = 5000;
    sensibleOnTop = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -as terminal-overrides ",xterm*:Tc"

      set -gq allow-passthrough on
      set -g visual-activity off
    '';
    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
    ];
  };

  programs.git = {
    enable = true;
    userName = "Benedikt von Blomberg";
    userEmail = "github@bvb.anonaddy.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = [
        "cache --timeout 21600"
      ];
      pull.rebase = true;
    };
  };

  programs.ranger = {
    enable = true;
  };
}
