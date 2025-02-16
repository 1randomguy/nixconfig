{ lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    git
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    neofetch
    wget
    ranger
    zk
    fzf
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    shortcut = "s";
    terminal = "tmux-256color";
    extraConfig = ''
      set -as terminal-overrides ",xterm*:Tc"
    '';
  };

  programs.git = {
    enable = true;
    userName = "Benedikt von Blomberg";
    userEmail = "github@bvb.anonaddy.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = [
        "cache --timeout 21600"
        "oauth"
      ];
      pull.rebase = true;
    };
  };

  programs.kitty = lib.mkForce {
    enable = true;
    font = {
      name = "JetBrainsMono";
      size = 14;
    };
  };

  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
    };
  };
}
