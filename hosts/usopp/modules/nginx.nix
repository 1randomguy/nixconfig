{config, ...}: 
{
  age.secrets.porkbun = {
    file = ../../../secrets/porkbun.age;
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."immich.shimagumo.party" = {
      enableACME = true;
      addSSL = true;
      #forceSSL = true;
      #sslCertificate = "/etc/ssl/selfsigned/selfsigned.crt";
      #sslCertificateKey = "/etc/ssl/selfsigned/selfsigned.key";
      locations."/" = {
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
    virtualHosts."adguard.shimagumo.party" = {
      enableACME = true;
      addSSL = true;
      #forceSSL = true;
      #sslCertificate = "/etc/ssl/selfsigned/selfsigned.crt";
      #sslCertificateKey = "/etc/ssl/selfsigned/selfsigned.key";
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.adguardhome.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "bblomberg123@gmail.com";
    certs."shimagumo.party" = {
      dnsProvider = "porkbun";
      environmentFile = config.age.secrets.porkbun.path;
    };
  };
  #services.nginx.virtualHosts.localhost = {
  #  locations."/" = {
  #    return = "200 '<html><body>It works</body></html>'";
  #    extraConfig = ''
  #      default_type text/html;
  #    '';
  #  };
  #};
}
