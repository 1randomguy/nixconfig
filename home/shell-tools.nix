{ lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    git
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    neofetch
    wget
    ranger
  ];

  programs.tmux = {
    enable = true;
    extraConfig = "set -g mouse on";
  };

  programs.git = {
    enable = true;
    userName = "Benedikt von Blomberg";
    userEmail = "github@bvb.anonaddy.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "oauth";
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
