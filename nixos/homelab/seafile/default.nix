{lib, config, ...}:
let
  cfg = config.homelab.services.seafile;
  hl = config.homelab;
in
{
  options.homelab.services.seafile = {
    enable = lib.mkEnableOption "Seafile Filesharing Service";
    directory = lib.mkOption {
      type = lib.types.str;
      description = "The directory on the server to share";
      default = "/data";
    };
  };
  config = lib.mkIf cfg.enable {
    services.seafile = {
      enable = true;

      adminEmail = "bblomberg123@gmail.com";
      initialAdminPassword = "changeme1234!";

      #dataDir = cfg.directory;
      ccnetSettings.General.SERVICE_URL = "https://seafile.${hl.baseDomain}";

      gc.enable = true;

      seafileSettings = {
        fileserver = {
          host = "unix:/run/seafile/server.sock";
          web_token_expire_time = 18000;
        };
      };
    };

    services.nginx.virtualHosts."seafile.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      enableAuthelia = false;

      locations = {
        "/" = {
          proxyPass = "http://unix:/run/seahub/gunicorn.sock";
          extraConfig = ''
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
            proxy_read_timeout  1200s;
            client_max_body_size 0;
          '';
        };
        "/seafhttp" = {
          proxyPass = "http://unix:/run/seafile/server.sock";
          extraConfig = ''
            rewrite ^/seafhttp(.*)$ $1 break;
            client_max_body_size 0;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout  36000s;
            proxy_read_timeout  36000s;
            proxy_send_timeout  36000s;
            send_timeout  36000s;
          '';
        };
      };
    };
  };
}
