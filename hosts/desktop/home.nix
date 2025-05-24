{ config, pkgs, inputs, ... }:

{
  imports =
    [ 
      ../../home/common.nix
      ../../home/shell
      ../../home/devel/base.nix
      ../../home/devel/rust.nix
      ../../home/apps/base.nix
      ../../home/apps/nextcloud.nix
      ../../home/apps/socials-private.nix
      ../../home/apps/hobby/image-editing.nix
      ../../home/apps/hobby/books.nix
      ../../home/apps/productivity/base.nix
      ../../home/apps/productivity/latex.nix
      ../../home/apps/productivity/uni-vpn.nix
      ./gnome-config.nix
    ];

  shell.zsh = {
    enable = true;
    p10k = true;
    nixos = true;
  };

  services.easyeffects = {
    enable = true;
    extraPresets = {
      hd58x = {
        output = {
            "blocklist" = [];
            "equalizer" = {
                "input-gain" = -10.4;
                "left" = {
                    "band0" = {
                        "frequency" = 25.0;
                        "gain" = 6.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Low-Shelf";
                    };
                    "band1" = {
                        "frequency" = 105.0;
                        "gain" = 4.5;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Low-Shelf";
                    };
                    "band2" = {
                        "frequency" = 160.0;
                        "gain" = -1.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.55;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band3" = {
                        "frequency" = 1350.0;
                        "gain" = -2.2;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 1.5;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band4" = {
                        "frequency" = 1900.0;
                        "gain" = 4.5;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "High-Shelf";
                    };
                    "band5" = {
                        "frequency" = 3250.0;
                        "gain" = -3.8;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 2.1;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band6" = {
                        "frequency" = 5400.0;
                        "gain" = -6.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 3.5;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band7" = {
                        "frequency" = 11000.0;
                        "gain" = -3.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "High-Shelf";
                    };
                };
                "mode" = "IIR";
                "num-bands" = 8;
                "output-gain" = 0.0;
                "right" = {
                    "band0" = {
                        "frequency" = 25.0;
                        "gain" = 6.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Low-Shelf";
                    };
                    "band1" = {
                        "frequency" = 105.0;
                        "gain" = 4.5;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Low-Shelf";
                    };
                    "band2" = {
                        "frequency" = 160.0;
                        "gain" = -1.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.55;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band3" = {
                        "frequency" = 1350.0;
                        "gain" = -2.2;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 1.5;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band4" = {
                        "frequency" = 1900.0;
                        "gain" = 4.5;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "High-Shelf";
                    };
                    "band5" = {
                        "frequency" = 3250.0;
                        "gain" = -3.8;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 2.1;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band6" = {
                        "frequency" = 5400.0;
                        "gain" = -6.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 3.5;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "Bell";
                    };
                    "band7" = {
                        "frequency" = 11000.0;
                        "gain" = -3.0;
                        "mode" = "RLC (BT)";
                        "mute" = false;
                        "q" = 0.71;
                        "slope" = "x1";
                        "solo" = false;
                        "type" = "High-Shelf";
                    };
                };
                "split-channels" = false;
            };
            "plugins_order" = [
                "equalizer"
            ];
        };
      };
    };
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
