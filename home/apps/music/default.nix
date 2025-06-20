{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.music;
in {
  options.apps.music = {
    enable = mkEnableOption "Music listening";
    eq = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the equalizer";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # music listening
      #quodlibet
      spotify
    ];
    services.easyeffects = mkIf cfg.eq {
      enable = true;
      extraPresets = {
        hd58x = {
          output = {
              "blocklist" = [];
              "equalizer" = {
                  "input-gain" = -10.4;
                  "left" = {
                      "band0" = {
                          "frequency" = 25.0;
                          "gain" = 6.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Low-Shelf";
                      };
                      "band1" = {
                          "frequency" = 105.0;
                          "gain" = 4.5;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Low-Shelf";
                      };
                      "band2" = {
                          "frequency" = 160.0;
                          "gain" = -1.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.55;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band3" = {
                          "frequency" = 1350.0;
                          "gain" = -2.2;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 1.5;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band4" = {
                          "frequency" = 1900.0;
                          "gain" = 4.5;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "High-Shelf";
                      };
                      "band5" = {
                          "frequency" = 3250.0;
                          "gain" = -3.8;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 2.1;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band6" = {
                          "frequency" = 5400.0;
                          "gain" = -6.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 3.5;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band7" = {
                          "frequency" = 11000.0;
                          "gain" = -3.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "High-Shelf";
                      };
                  };
                  "mode" = "IIR";
                  "num-bands" = 8;
                  "output-gain" = 0.0;
                  "right" = {
                      "band0" = {
                          "frequency" = 25.0;
                          "gain" = 6.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Low-Shelf";
                      };
                      "band1" = {
                          "frequency" = 105.0;
                          "gain" = 4.5;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Low-Shelf";
                      };
                      "band2" = {
                          "frequency" = 160.0;
                          "gain" = -1.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.55;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band3" = {
                          "frequency" = 1350.0;
                          "gain" = -2.2;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 1.5;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band4" = {
                          "frequency" = 1900.0;
                          "gain" = 4.5;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "High-Shelf";
                      };
                      "band5" = {
                          "frequency" = 3250.0;
                          "gain" = -3.8;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 2.1;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band6" = {
                          "frequency" = 5400.0;
                          "gain" = -6.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 3.5;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "Bell";
                      };
                      "band7" = {
                          "frequency" = 11000.0;
                          "gain" = -3.0;
                          "mode" = "RLC (BT)";
                          "mute" = false;
                          "q" = 0.71;
                          "slope" = "x1";
                          "solo" = false;
                          "type" = "High-Shelf";
                      };
                  };
                  "split-channels" = false;
              };
              "plugins_order" = [
                  "equalizer"
              ];
          };
        };
      };
    };
  };
}
