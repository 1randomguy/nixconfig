{ self, ... }:
{
  flake.nixosModules.vicinae =
    { pkgs, lib, ... }:
    let
      vicinaeNixConfig = pkgs.writeText "vicinae-nix-settings.json" (
        builtins.toJSON {
          close_on_focus_loss = true;
          pop_to_root_on_close = true;
          theme.dark.name = "catppuccin-macchiato";
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
          Environment = "PATH=${
            lib.makeBinPath [
              pkgs.bash
              pkgs.systemd
              pkgs.coreutils
              pkgs.util-linux
              pkgs.playerctl
              pkgs.pwvucontrol
              pkgs.networkmanager
              pkgs.niri
            ]
          }";
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
