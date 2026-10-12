{
  flake.nixosModules.ntfy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.homelab.notify;
      hostName = config.networking.hostName;
      ntfyUrlFile = config.age.secrets.ntfy_url.path;

      # Shared mailer shim. Used by smartd (invoked as `-i <addr>`, SMARTD_* in
      # env) and ZED (invoked as `-s <subject> <addr>`). Body arrives on stdin.
      ntfyMailer = pkgs.writeShellScript "ntfy-mailer" ''
        set -u
        TITLE="''${SMARTD_SUBJECT:-Notification from ${hostName}}"
        while [ "$#" -gt 0 ]; do
          case "$1" in
            -s)
              shift
              TITLE="''${1:-$TITLE}"
              ;;
          esac
          shift
        done
        URL="$(cat ${ntfyUrlFile})"
        ${pkgs.curl}/bin/curl -sf \
          -H "Title: ''${TITLE}" \
          -H "Tags: warning" \
          -H "Priority: high" \
          --data-binary @- \
          "$URL"
      '';

      # Template notifier: invoked as `ntfy-notify@<unit>.service` and posts the
      # failed unit's journal tail.
      ntfyNotify = pkgs.writeShellScript "ntfy-notify" ''
        set -u
        UNIT="''${1:-unknown}"
        URL="$(cat ${ntfyUrlFile})"
        ${pkgs.systemd}/bin/journalctl -u "$UNIT" -n 40 --no-pager \
          | ${pkgs.curl}/bin/curl -sf \
              -H "Title: ${hostName}: ''${UNIT} failed" \
              -H "Tags: warning" \
              -H "Priority: high" \
              --data-binary @- \
              "$URL"
      '';

      storageScript = pkgs.writeShellScript "storage-alert" ''
        set -u
        THRESHOLD=${toString cfg.storage.threshold}
        URL="$(cat ${ntfyUrlFile})"
        ALERTS=""
        add_alert() {
          ALERTS="''${ALERTS}''${ALERTS:+
}$1"
        }

        ${lib.concatMapStrings (mount: ''
          if ! ${pkgs.util-linux}/bin/mountpoint -q ${mount}; then
            add_alert "MISSING MOUNT: ${mount}"
          fi
        '') cfg.storage.mounts}

        ${lib.concatMapStrings (pool: ''
          cap="$(${config.boot.zfs.package}/bin/zpool list -H -o capacity ${pool} 2>/dev/null | tr -d '%')"
          if [ -n "$cap" ] && [ "$cap" -ge "$THRESHOLD" ]; then
            add_alert "ZFS pool ${pool} at ''${cap}%"
          fi
        '') cfg.storage.pools}

        ${lib.concatMapStrings (path: ''
          cap="$(${pkgs.coreutils}/bin/df --output=pcent ${path} 2>/dev/null | tail -n 1 | tr -dc '0-9')"
          if [ -n "$cap" ] && [ "$cap" -ge "$THRESHOLD" ]; then
            add_alert "${path} at ''${cap}%"
          fi
        '') cfg.storage.paths}

        if [ -n "$ALERTS" ]; then
          ${pkgs.curl}/bin/curl -sf \
            -H "Title: Storage warning on ${hostName}" \
            -H "Tags: warning" \
            -H "Priority: high" \
            -d "Storage usage at/over ''${THRESHOLD}%:
''${ALERTS}" \
            "$URL"
        fi
      '';

      healthScript = pkgs.writeShellScript "system-health-check" ''
        set -u
        URL="$(cat ${ntfyUrlFile})"

        failed="$(${pkgs.systemd}/bin/systemctl list-units --state=failed --no-legend --no-pager --plain 2>/dev/null)"
        if [ -n "$failed" ]; then
          ${pkgs.curl}/bin/curl -sf \
            -H "Title: Failed systemd units on ${hostName}" \
            -H "Tags: warning" \
            -H "Priority: high" \
            --data-binary "$failed" \
            "$URL"
        fi

        booted="$(${pkgs.coreutils}/bin/readlink -f /run/booted-system 2>/dev/null || true)"
        current="$(${pkgs.coreutils}/bin/readlink -f /run/current-system 2>/dev/null || true)"
        if [ -n "$booted" ] && [ -n "$current" ] && [ "$booted" != "$current" ]; then
          ${pkgs.curl}/bin/curl -sf \
            -H "Title: Reboot required on ${hostName}" \
            -H "Tags: rotating_light" \
            -d "The running system differs from the current generation. A reboot is pending." \
            "$URL"
        fi
      '';

      dockerScript = pkgs.writeShellScript "docker-error-notify" ''
        set -u
        URL="$(cat ${ntfyUrlFile})"
        ${config.virtualisation.docker.package}/bin/docker events \
          --filter 'event=die' \
          --filter 'event=health_status' \
          --format '{{.Action}}|{{.Actor.Attributes.name}}|{{.Actor.Attributes.exitCode}}' \
        | while IFS='|' read -r action name code; do
            case "$action" in
              die)
                [ "''${code:-0}" = "0" ] && continue
                msg="Container '$name' died (exit code: ''${code:-unknown})"
                ;;
              "health_status: unhealthy")
                msg="Container '$name' is unhealthy"
                ;;
              *)
                continue
                ;;
            esac
            ${pkgs.curl}/bin/curl -sf \
              -H "Title: Docker alert on ${hostName}" \
              -H "Tags: warning" \
              -H "Priority: high" \
              -d "$msg" \
              "$URL" || true
          done
      '';
    in
    {
      config = lib.mkMerge [
        {
          age.secrets.ntfy_url.file = ../../../../secrets/ntfy_url.age;

          systemd.services."ntfy-notify@" = {
            description = "Send ntfy notification for failed unit %i";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${ntfyNotify} %i";
            };
          };
        }

        # Restic backups (repository state directories)
        (lib.mkIf (config.services.restic.backups != { }) {
          systemd.services = lib.mapAttrs' (
            name: _:
            lib.nameValuePair "restic-backups-${name}" {
              unitConfig.OnFailure = [ "ntfy-notify@%n.service" ];
            }
          ) config.services.restic.backups;
        })

        # PostgreSQL dumps that feed restic
        (lib.mkIf config.services.postgresqlBackup.enable {
          systemd.services =
            if config.services.postgresqlBackup.backupAll then
              {
                postgresqlBackup.unitConfig.OnFailure = [ "ntfy-notify@%n.service" ];
              }
            else
              lib.listToAttrs (
                map (db: lib.nameValuePair "postgresqlBackup-${db}" {
                  unitConfig.OnFailure = [ "ntfy-notify@%n.service" ];
                }) config.services.postgresqlBackup.databases
              );
        })

        # SMART disk health
        (lib.mkIf config.services.smartd.enable {
          services.smartd.notifications.mail = {
            enable = true;
            mailer = "${ntfyMailer}";
          };
        })

        # ZFS pool health (state changes / scrub / resilver) via ZED
        (lib.mkIf config.boot.zfs.enabled {
          services.zfs.zed = {
            enableMail = false;
            settings = {
              ZED_EMAIL_ADDR = [ "root" ];
              ZED_EMAIL_PROG = "${ntfyMailer}";
              ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";
              ZED_NOTIFY_VERBOSE = false;
            };
          };
        })

        # Docker container failures / unhealthy containers
        (lib.mkIf config.virtualisation.docker.enable {
          systemd.services."docker-error-notify" = {
            description = "Notify on failing or unhealthy docker containers";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "60";
              ExecStart = "${dockerScript}";
            };
          };
        })

        # Immich auto-stacker container run
        (lib.mkIf (config.virtualisation.docker.enable && config.services.immich.enable) {
          systemd.services."immich-auto-stacker".unitConfig.OnFailure = [ "ntfy-notify@%n.service" ];
        })

        # Storage capacity + mount presence
        (lib.mkIf (cfg.storage.pools != [ ] || cfg.storage.paths != [ ]) {
          systemd.services."storage-alert" = {
            description = "Warn when storage usage is high";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${storageScript}";
            };
          };
          systemd.timers."storage-alert" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "hourly";
              Persistent = true;
            };
          };
        })

        # Failed units + reboot-required digest
        {
          systemd.services."system-health-check" = {
            description = "Report failed units and pending reboots";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${healthScript}";
            };
          };
          systemd.timers."system-health-check" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
            };
          };
        }

        # NixOS auto-upgrade result
        (lib.mkIf config.system.autoUpgrade.enable {
          systemd.services.nixos-upgrade.serviceConfig.ExecStopPost =
            "${pkgs.writeShellScript "upgrade-notify" ''
              WEBHOOK_URL=$(cat ${ntfyUrlFile})

              CURRENT_SYS=$(readlink /run/current-system)
              NEW_SYS=$(readlink /nix/var/nix/profiles/system)

              if [ "$EXIT_STATUS" = "0" ]; then
                # Only notify if the system path actually changed
                if [ "$CURRENT_SYS" != "$NEW_SYS" ]; then
                  ${pkgs.curl}/bin/curl \
                    -H "Title: NixOS Upgrade Success" \
                    -H "Tags: white_check_mark" \
                    -d "Server updated successfully to the latest GitHub commit." \
                    "$WEBHOOK_URL"
                else
                  echo "No changes detected in the flake. Staying quiet."
                fi
              else
                # Grab the last 50 lines of the journal on failure
                ${pkgs.systemd}/bin/journalctl -u nixos-upgrade.service -n 50 --no-pager | \
                ${pkgs.curl}/bin/curl \
                  -H "Title: NixOS Upgrade FAILED" \
                  -H "Tags: warning" \
                  -d @- \
                  "$WEBHOOK_URL"
              fi
            ''}";
        })
      ];
    };
}
