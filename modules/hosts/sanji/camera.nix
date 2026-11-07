{ ... }:
{
  flake.nixosModules.sanjiCamera =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (
          final: prev: {
            libcamera-imx471 = prev.libcamera.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./libcamera-imx471.patch
                ./libcamera-swstats-sumshift.patch
              ];

              postInstall = (old.postInstall or "") + ''
                install -Dm644 ${./imx471.yaml} $out/share/libcamera/ipa/simple/imx471.yaml
              '';
            });

            snapshot = prev.snapshot.override {
              libcamera = final.libcamera-imx471;
            };
          }
        )
      ];

      boot.kernelModules = [
        "imx471"
        "ipu-bridge"
      ];

      environment.systemPackages = [ pkgs.libcamera-imx471 ];

      services.pipewire = {
        package = pkgs.pipewire.override { libcamera = pkgs.libcamera-imx471; };
        wireplumber.package = pkgs.wireplumber.override {
          pipewire = pkgs.pipewire.override { libcamera = pkgs.libcamera-imx471; };
        };
      };
    };
}
