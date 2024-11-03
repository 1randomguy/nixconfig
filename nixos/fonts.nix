{pkgs, ...}:
{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono 
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono" ];
      };
    };
  };
}
