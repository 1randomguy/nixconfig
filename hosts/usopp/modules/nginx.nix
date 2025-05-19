{config, ...}: 
{
  services.nginx = {
    enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx.virtualHosts.localhost = {
    enableACME = true;
    forceSSL = true;
    locations."/immich" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
  services.nginx.virtualHosts.localhost = {
    locations."/" = {
      return = "200 '<html><body>It works</body></html>'";
      extraConfig = ''
        default_type text/html;
      '';
    };
  };
}
