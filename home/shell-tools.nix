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
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
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
      credential.helper = "oauth";
      pull.rebase = true;
    };
  };

  programs.kitty = lib.mkForce {
    enable = true;
    font = {
      name = "JetBrainsMono";
      size = 14;
    };
    # settings = {
    #   #conf;
    # };
  };

  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
    };
  };
}
