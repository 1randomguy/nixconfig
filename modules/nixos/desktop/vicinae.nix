{ self, ... }:
{
  flake.nixosModules.vicinae =
    { pkgs, config, ... }:
    let
      niriWorkspaceScript = pkgs.writeScript "nw.sh" ''
        #!/usr/bin/env bash
        # @vicinae.schemaVersion 1
        # @vicinae.title Niri Workspace Helper
        # @vicinae.icon 📜
        # @vicinae.description Rename or change workspaces
        # @vicinae.keywords ["nw", "niri", "workspace"]
        # @vicinae.mode silent
        # @vicinae.exec ["${pkgs.bash}/bin/bash"]
        # @vicinae.argument1 { "type": "text", "placeholder": "Workspace name", "optional": true }

        if [ -z "''$1" ]; then
          echo "Removing Workspace Name"
          exec niri msg action unset-workspace-name
        fi

        if WORKSPACES=''$(niri msg --json workspaces 2>/dev/null); then
          if echo "''$WORKSPACES" | ${pkgs.jq}/bin/jq -e --arg name "''$1" '.[] | select(.name == ''$name)' >/dev/null; then
            echo "Changing to Workspace: ''$1"
            exec niri msg action focus-workspace "''$1"
          fi
        fi

        echo "Renaming Workspace to: ''$1"
        exec niri msg action set-workspace-name "''$1"
      '';
      vicinateCustomScriptsDir = pkgs.linkFarm "vicinae-custom-scripts" [
        {
          name = "nw.sh";
          path = niriWorkspaceScript;
        }
      ];
      vicinaeNixConfig = pkgs.writeText "vicinae-nix-settings.json" (
        builtins.toJSON {
          close_on_focus_loss = true;
          pop_to_root_on_close = true;
          theme.dark.name = "catppuccin-mocha";
          font.normal = {
            family = "Adwaita Sans";
            size = 11.5;
          };
          providers = {
            calculator.entrypoints.history.alias = "=";
            files.entrypoints.search = {
              enabled = true;
              alias = "/";
            };
            core.entrypoints = {
              about.enabled = false;
              report-bug.enabled = false;
              sponsor.enabled = false;
            };
            scripts.preferences.customDirs = [
              vicinateCustomScriptsDir
            ];
          };
        }
      );
    in
    {
      environment.systemPackages = [ pkgs.vicinae ];

      systemd.user.services.vicinae = {
        enable = true;
        description = "Vicinae for Niri";

        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];

        wantedBy = [ "niri.service" ];

        serviceConfig = {
          Type = "simple";
          # Environment = "PATH=${
          #   lib.makeBinPath [
          #     pkgs.bash
          #     pkgs.systemd
          #     pkgs.coreutils
          #     pkgs.util-linux
          #     pkgs.playerctl
          #     pkgs.pwvucontrol
          #     pkgs.networkmanager
          #     pkgs.niri
          #     pkgs.firefox
          #   ]
          # }";
          Environment = "PATH=${pkgs.lib.makeBinPath config.environment.systemPackages}:/run/current-system/sw/bin";
          ExecStartPre = "${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY";
          ExecStart = "${pkgs.vicinae}/bin/vicinae server"; # --config ${./vicinae.json}
          Restart = "always";
          RestartSec = 1;
        };
      };

      system.activationScripts.vicinaeBootstrap = {
        text = ''
          USER="bene"
          CONFIG_DIR="/home/$USER/.config/vicinae"
          TARGET_FILE="$CONFIG_DIR/settings.json"

          # Ensure the directory exists
          mkdir -p "$CONFIG_DIR"

          # Only write the bootstrap file if it doesn't exist,
          # preventing us from wiping out any GUI-made changes on a rebuild.
          if [ ! -f "$TARGET_FILE" ]; then
            printf '{\n  "imports": [\n    "%s"\n  ]\n}\n' "${vicinaeNixConfig}" > "$TARGET_FILE"
          else
            # If it does exist, we can use jq (or simple sed/python) to safely update 
            # the imports array to the new Nix store path while preserving GUI settings.
            # For simplicity, here we just update the specific import path:
            # ${pkgs.jq}/bin/jq --arg nixpath "${vicinaeNixConfig}" '.imports = [$nixpath]' "$TARGET_FILE" > "$TARGET_FILE.tmp" && mv "$TARGET_FILE.tmp" "$TARGET_FILE"
            ${pkgs.gnused}/bin/sed 's/^ *\/\/.*//' "$TARGET_FILE" | \
            ${pkgs.jq}/bin/jq --arg nixpath "${vicinaeNixConfig}" '
              try (
                .imports = [$nixpath]
              ) catch (
                # If the file was malformed, fallback to bootstrapping a clean object
                { "imports": [$nixpath] }
              )
            ' > "$TARGET_FILE.tmp" && mv "$TARGET_FILE.tmp" "$TARGET_FILE"
          fi

          # Ensure permissions are correct for the user
          chown -R $USER:users "$CONFIG_DIR"
          chmod 644 "$TARGET_FILE"
        '';
      };
    };
}
