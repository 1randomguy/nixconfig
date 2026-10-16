{ ... }:
{
  flake.nixosModules.syncthing =
    { ... }:
    {
      # gui available at: 127.0.0.1:8384
      services.syncthing = {
        enable = true;
        user = "bene";
        group = "users";
        dataDir = "/home/bene";
        openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
      };
    };
}
