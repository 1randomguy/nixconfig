{
  flake.nixosModules.latex = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
      texworks
      zathura
      # kile
      kile
      ghostscript_headless
    ];
  };
}
