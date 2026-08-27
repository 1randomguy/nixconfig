{
  inputs,
  self,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      hostUser = "bene";

      jail = inputs.jail-nix.lib.extend {
        inherit pkgs;
        basePermissions =
          combinators:
          with combinators;
          [
            base
            (readonly "/nix/store")
            fake-passwd
          ];
      };

      sandboxPackages = with pkgs; [
        opencode
        git
        ripgrep
        fd
        jq
        nodejs
        python3
        gcc
        gnumake
        toybox
        htop
        fzf
        lazygit
        dig
        rename
        nix-prefetch-scripts
        direnv
        tmux
        self.packages.${system}.neovim
        self.packages.${system}.zsh
        nix
      ];
    in
    {
      packages.ai-jail = jail "ai-jail" self.packages.${system}.zsh (
        with jail.combinators;
        [
          (add-runtime ''
            AIJ_CDIR=""
            while [ "$#" -gt 0 ]; do
              case "$1" in
                --bind)
                  if [ "$#" -lt 2 ]; then
                    echo "ai-jail: --bind requires a path" >&2
                    exit 1
                  fi
                  if [ ! -e "$2" ]; then
                    echo "ai-jail: --bind: no such path: $2" >&2
                    exit 1
                  fi
                  P="$(realpath "$2")"
                  RUNTIME_ARGS+=(--bind "$P" "$P")
                  shift 2
                  ;;
                --ro-bind)
                  if [ "$#" -lt 2 ]; then
                    echo "ai-jail: --ro-bind requires a path" >&2
                    exit 1
                  fi
                  if [ ! -e "$2" ]; then
                    echo "ai-jail: --ro-bind: no such path: $2" >&2
                    exit 1
                  fi
                  P="$(realpath "$2")"
                  RUNTIME_ARGS+=(--ro-bind "$P" "$P")
                  shift 2
                  ;;
                *)
                  if [ -e "$1" ]; then
                    P="$(realpath "$1")"
                    RUNTIME_ARGS+=(--bind "$P" "$P")
                    if [ -d "$1" ]; then
                      AIJ_CDIR="$P"
                    fi
                  fi
                  shift
                  ;;
              esac
            done
            RUNTIME_ARGS+=(--setenv AIJ_CDIR "$AIJ_CDIR")
          '')
          (set-argv [ ])
          (add-pkg-deps sandboxPackages)
          network
          (persist-home "ai-home")
          (rw-bind "/home/${hostUser}/Code" "/home/${hostUser}/Code")
          (ro-bind "/home/${hostUser}/.config/opencode" "/home/${hostUser}/.config/opencode")
          (set-env "TERM" "xterm-256color")
          (set-env "COLORTERM" "truecolor")
          (set-env "NIX_CONFIG" "experimental-features = nix-command flakes")
          (set-env "LANG" "en_US.UTF-8")
          (set-env "LC_ALL" "en_US.UTF-8")
          (set-env "LOCALE_ARCHIVE" "${pkgs.glibcLocales}/lib/locale/locale-archive")
          no-new-session
          (wrap-entry
            (entry: ''
              echo "========================================================"
              echo " Isolated AI Sandbox (jail.nix)"
              echo " Usage: ai-jail [--bind DIR | --ro-bind DIR | DIR ...]"
              echo "========================================================"
              if [ -n "$AIJ_CDIR" ]; then
                if ! cd "$AIJ_CDIR" 2>/dev/null; then
                  echo "ai-jail: could not cd to $AIJ_CDIR, starting in ~/Code" >&2
                  cd "/home/${hostUser}/Code" 2>/dev/null || true
                fi
              else
                cd "/home/${hostUser}/Code" 2>/dev/null || true
              fi
              exec ${entry} -i
            ''))
        ]
      );

      apps.ai-jail = {
        type = "app";
        program = "${self.packages.${system}.ai-jail}/bin/ai-jail";
      };
    };
}
