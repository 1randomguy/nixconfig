{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, self', system, ... }: {
    packages.hyprlock = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = pkgs.hyprlock;
      binName = "hyprlock";
      flags = {
        "--config" = "${./hyprlock.conf}";
      };
    });
    packages.hyprlockSmart = pkgs.writeShellApplication {
      name = "lock";
      text = ''
        if ! ${pkgs.procps}/bin/pgrep -x hyprlock > /dev/null; then
          ${self'.packages.hyprlock}/bin/hyprlock&
          # ${self'.packages.hyprlock}/bin/hyprlock > /dev/null 2>&1 &
          # # Disown the process so the shell completely forgets about it
          # disown
          # This is the "Magic Buffer" that kills the flicker
          ${pkgs.coreutils}/bin/sleep 1
        fi
      '';
    };

  };
}
