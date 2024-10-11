{pkgs, ...}:

{
  nixpkgs.config.permittedInsecurePackages = [
                "electron-27.3.11"
                ];
  users.users.bene.packages = with pkgs; [
    logseq
    rnote
  ];
}
