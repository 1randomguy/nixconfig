{
  inputs,
  self,
  ...
}:
{
  flake.zshWrapper =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.zsh ];

      options.p10k = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable p10k prompt";
      };
      options.historyKeymaps = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable history keymaps";
      };

      config = {
        skipGlobalRC = true;
        # env.EDITOR = "nvim";
        runtimePkgs = [
          pkgs.zoxide
        ];
        zshrc.content = lib.mkMerge [
          ''
            # --- Base Configuration ---
            # Replaces history.size = 10000;
            HISTSIZE=10000
            SAVEHIST=10000

            # Replaces enableCompletion, autosuggestion, syntaxHighlighting
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

            autoload -Uz compinit && compinit

            # --- Oh My Zsh Setup ---
            # To simulate HM's oh-my-zsh module without HM, source the main file 
            # and explicitly load the requested plugins from the store package
            export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
            plugins=(git sudo colored-man-pages extract tmux)
            for plugin in $plugins; do
              if [ -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]; then
                source "$ZSH/plugins/$plugin/$plugin.plugin.zsh"
              fi
            done

            source "$ZSH/oh-my-zsh.sh"

            source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
          ''

          ''
            eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          ''

          # (lib.mkIf config.historyKeymaps ''
          #   # these don't work in wsl e.g.
          #   autoload -Uz up-line-or-search down-line-or-search
          #   zmodload zsh/terminfo
          #   typeset -gA key
          #   key[Up]="$terminfo[kcuu1]"
          #   key[Down]="$terminfo[kcud1]"
          #   [[ -n "$key[Up]"   ]] && bindkey "$key[Up]"   up-line-or-search
          #   [[ -n "$key[Down]" ]] && bindkey "$key[Down]" down-line-or-search
          # '')

          # --- Powerlevel10k Conditional Block ---
          (lib.mkIf config.p10k ''
            # Instant prompt implementation
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

            # Source the standalone theme script
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

            # Look for your custom p10k.zsh file relative to where this flake module lives
            [[ ! -f ${./config/p10k.zsh} ]] || source ${./config/p10k.zsh}

            # Replaces home.packages = [ any-nix-shell ] via inline invocation
            ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
          '')

          # --- Post-Initialization Block (mkAfter equivalent) ---
          ''
            eval "$(direnv hook zsh)"
            autoload -Uz edit-command-line
            zle -N edit-command-line
            bindkey "^x^e" edit-command-line

            # Function to set the Ghostty title
            set_window_title() {
              # \e]2; is the escape sequence to start the title
              # \a (or \x07) terminates it
              print -Pn "\e]2;$1\a"
            }

            # Runs right before the prompt is drawn (when idle)
            precmd() {
              # %~ shows the current path, shortening home to '~'
              set_window_title "zsh (%~)"
            }

            # Runs right before a command executes
            preexec() {
              # $1 is the raw command you just typed
              set_window_title "$1 (%~)"
            }
          ''

          ''
            alias lg='lazygit'
          ''
        ];
      };
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        imports = [ self.zshWrapper ];
      };
      packages.zsh-mini = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        imports = [
          self.zshWrapper
          { p10k = false; }
        ];
      };
    };
}
