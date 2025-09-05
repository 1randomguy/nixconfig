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
    outputDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zola-blog";
      description = "Directory where built site will be stored";
    };
  };

  config = lib.mkIf cfg.enable {
    # backup the blog source
    homelab.services.restic.backupDirs = [ cfg.sourceDir ];

    # Entr-based activation to rebuild on changes
    systemd.services.zola-blog-watch = {
      description = "Watch for blog changes and rebuild";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.sourceOwner;
        WorkingDirectory = cfg.sourceDir;
        Restart = "always";
        RestartSec = 5;
        # Security restrictions
        NoNewPrivileges = true;
        PrivateTmp = true;
        #ProtectSystem = "strict";
        #ProtectHome = true;
        #ReadOnlyPaths = [ cfg.sourceDir ];
        #ReadWritePaths = [ cfg.outputDir ];
        # Network restrictions (zola build doesn't need network)
        PrivateNetwork = true;
      };
      
      script = ''
        find ${cfg.sourceDir} -type f \( -name "*.md" -o -name "*.toml" -o -name "*.html" \) | \
        ${pkgs.entr}/bin/entr -n -r ${pkgs.zola}/bin/zola build --output-dir ${cfg.outputDir}/www --force
      '';
      
      path = [ pkgs.entr pkgs.findutils pkgs.zola ];
    };

    # Path-based activation to rebuild on changes
    systemd.paths.zola-blog-path-watch = {
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathModified = cfg.sourceDir;
        Unit = "zola-blog-watch.service";
      };
    };

    # Nginx configuration
    services.nginx.virtualHosts."blog.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = "${cfg.outputDir}/www";
      
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
      };
    };

    # Ensure the output directory has correct permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.outputDir} 0755 ${cfg.sourceOwner} nginx -"
    ];
  };
}
