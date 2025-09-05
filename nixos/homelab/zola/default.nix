{config, lib, pkgs, ...}:
let
  cfg = config.homelab.services.zola;
  hl = config.homelab;
in
{
  options.homelab.services.zola = {
    enable = lib.mkEnableOption "Zola static site generator & server";
    sourceDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to your blog source directory";
      example = "/home/user/blog";
    };
    sourceOwner = lib.mkOption {
      type = lib.types.str;
      description = "User that owns your blog source directory";
      example = "user";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port for the Zola server";
    };
  };

  config = lib.mkIf cfg.enable {
    # backup the blog source
    homelab.services.restic.backupDirs = [ cfg.sourceDir ];

    # Systemd service to serve the blog
    systemd.services.zola-blog = {
      description = "Build Zola blog";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "exec";
        User = cfg.sourceOwner;
        WorkingDirectory = cfg.sourceDir;
        ExecStart = "${pkgs.zola}/bin/zola serve --interface 127.0.0.1 --port ${toString cfg.port}";
        Restart = "always";
      };
    };

    # Nginx configuration
    services.nginx.virtualHosts."blog.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        # Set headers
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
      '';

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
