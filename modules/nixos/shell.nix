{ self, inputs, ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;

      # TODO: make a wrapped zsh shell
      environment.systemPackages = [
        selfpkgs.neovim
        selfpkgs.zsh
        pkgs.toybox
        pkgs.git
        pkgs.git-credential-oauth
        pkgs.just
        pkgs.fastfetch
        pkgs.htop
        pkgs.nix-prefetch-scripts
        pkgs.fzf
        pkgs.mosh
        pkgs.gemini-cli
        pkgs-unstable.antigravity-cli
        pkgs.rename
        pkgs.devenv
        pkgs.exiftool
        pkgs.ripgrep
        pkgs.fd
        pkgs.dig
        pkgs.gh
        pkgs.lazygit
        pkgs.cifs-utils
      ];
      programs.yazi = {
        enable = true;
        plugins = {
          git = pkgs.yaziPlugins.git;
        };
        initLua = pkgs.writeText "init.lua" ''
          require("git"):setup {
            -- Order of status signs showing in the linemode
            order = 1500,
          }
        '';
        settings = {
          yazi = {
            mgr = {
              show_hidden = true;
            };
            plugin = {
              prepend_fetchers = [
                {
                  url = "*";
                  run = "git";
                  group = "git";
                }
                {
                  url = "*/";
                  run = "git";
                  group = "git";
                }
              ];
            };
          };
          theme = {
            filetype = {
              prepend_rules = [
                {
                  url = "*";
                  is = "hidden";
                  fg = "darkgray";
                }
                {
                  url = "*/";
                  is = "hidden";
                  fg = "darkgray";
                }
              ];
            };
            git = {
              ignored = {
                fg = "darkgray";
              };
            };
          };
        };
      };

      programs.git = {
        enable = true;
        config = {
          user.name = "Benedikt von Blomberg";
          user.email = "bblomberg123@gmail.com";
          init.defaultBranch = "main";
          credential.helper = [
            "cache --timeout 21600"
            "oauth"
          ];
          pull.rebase = true;
        };
      };

      programs.direnv = {
        enable = true;
        settings = {
          global = {
            hide_env_diff = true;
          };
        };
      };

      programs.tmux = {
        enable = true;
        historyLimit = 5000;
        shortcut = "b";
        terminal = "tmux-256color";
        extraConfig = ''
          set -as terminal-overrides ",xterm*:Tc"

          set -gq allow-passthrough on
          set -g visual-activity off

          set -g mouse on
        '';
      };
    };
}
