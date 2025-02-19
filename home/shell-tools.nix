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
    ghostty
    wezterm
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    historyLimit = 5000;
    shortcut = "s";
    terminal = "tmux-256color";
    extraConfig = ''
      set -as terminal-overrides ",xterm*:Tc"
      
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=blue'

      set -g status-left ""
      set -g status-left-length 10

      set -g status-right-style 'fg=yellow bg=black'
      set -g status-right '%Y-%m-%d %H:%M '
      set -g status-right-length 50
      
      setw -g window-status-current-style 'fg=black bg=blue'
      setw -g window-status-current-format ' #I #W #F '

      setw -g window-status-style 'fg=blue bg=black'
      setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F 
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
