{ lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    git
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    python312Packages.pylatexenc
    neofetch
    wget
    zk
    fzf
    wl-clipboard
    any-nix-shell
    just
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    #historyLimit = 5000;
    sensibleOnTop = true;
    shortcut = "s";
    terminal = "tmux-256color";
    extraConfig = ''
      set -as terminal-overrides ",xterm*:Tc"

      set -gq allow-passthrough on
      set -g visual-activity off
    '';
    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
      tmuxPlugins.catppuccin
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
    themeFile = "Catppuccin-Mocha";
    settings = {
      wayland_titlebar_color = "background";
    };
  };

  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
    };
  };

  programs.lf = {
    enable = true;
    extraConfig = ''
    set previewer ${./config/lf_previewer.sh}
    set cleaner ${./config/lf_cleaner.sh}
    '';
  };
}
