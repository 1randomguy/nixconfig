{ self, inputs, ... }:
{
  flake.nixosModules.games =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.games;
    in
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      options.games = {
        steam.enable = lib.mkEnableOption "Enable Steam";
        bottles.enable = lib.mkEnableOption "Enable Bottles and VN translation tools";
      };

      config = {
        services.flatpak.packages =
          [ "sh.ppy.osu" ]
          ++ lib.optionals cfg.steam.enable [ "com.valvesoftware.Steam" ]
          ++ lib.optionals cfg.bottles.enable [ "com.usebottles.bottles" ];

        programs.cdemu.enable = true;

        environment.systemPackages = with pkgs; [
          gamescope
        ];
      };
    };
}
