{ config, pkgs, inputs, ... }:

{
  imports =
    [ 
      ../../home/common.nix
      ../../home/shell
      ../../home/apps/nextcloud.nix
      ../../home/apps/socials-private.nix
      ../../home/gnome
      ../../home/apps
    ];

  apps = {
    enable = true;
    latex.enable = true;
    uni_vpn.enable = true;
    image_editing.enable = true;
    music = {
      enable = true;
      eq = true;
    };
    devel = {
      enable = true;
    };
  };

  shell = {
    zsh = {
      enable = true;
      p10k = true;
    };
    ghostty.enable = true;
    tmux.enable = true;
    zk.enable = true;
  };

  gnome_customizations = {
    enable = true;
    wallpaper = "/home/bene/nixconfig/assets/wallpapers/XE030210.JPG";
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "bene";
  home.homeDirectory = "/home/bene";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/bene/etc/profile.d/hm-session-vars.sh
  #



  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
