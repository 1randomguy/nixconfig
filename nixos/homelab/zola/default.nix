{config, lib, pkgs, ...}:
let
  cfg = config.homelab.services.zola;
  hl = config.homelab;
in
{
  options.services.zola = {
    mkEnable = lib.mkEnableOption "Zola static site generator & server";
    sourceDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to your blog source directory";
      example = "/home/user/blog";
    };
    outputDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/zola-blog";
      description = "Directory where built site will be stored";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create user for the blog service
    users.users.zola-blog = {
      isSystemUser = true;
      group = cfg.user;
      home = cfg.outputDir;
      createHome = false;
    };

    users.groups.zola-blog = {};

    # Systemd service to build the blog
    systemd.services.zola-blog-build = {
      description = "Build Zola blog";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = cfg.sourceDir;
        ExecStart = "${pkgs.zola}/bin/zola build --output-dir ${cfg.outputDir}";
        RemainAfterExit = true;
      };

      # Rebuild when source directory changes
      path = [ pkgs.zola ];
    };

    # Path-based activation to rebuild on changes
    systemd.paths.zola-blog-watch = lib.mkIf cfg.buildOnChange {
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathModified = cfg.sourceDir;
        Unit = "zola-blog-build.service";
      };
    };

    # Nginx configuration
    services.nginx.virtualHosts."blog.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      root = cfg.outputDir;
      
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
      };
    };

    # Ensure the output directory has correct permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.outputDir} 0755 ${cfg.user} ${cfg.user} -"
    ];
  };
}
