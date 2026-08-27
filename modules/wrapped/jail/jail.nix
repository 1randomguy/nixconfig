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
      packages.opencode-jail = jail "opencode-jail" self.packages.${system}.zsh (
        with jail.combinators;
        [
          (add-pkg-deps sandboxPackages)
          network
          (persist-home "opencode-agent")
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
              echo " OpenCode Isolated Sandbox (jail.nix)"
              echo " Persistent but isolated \$HOME. Native I/O on ~/Code"
              echo "========================================================"
              cd "/home/${hostUser}/Code" 2>/dev/null || true
              exec ${entry} -i
            ''))
        ]
      );

      apps.opencode-jail = {
        type = "app";
        program = "${self.packages.${system}.opencode-jail}/bin/opencode-jail";
      };
    };
}
