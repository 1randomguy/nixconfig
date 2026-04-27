{
  flake.nixosModules.latex = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
      tectonic
      texworks
      zathura
      # kile
      kile
      ghostscript_headless
    ];
  };
}
