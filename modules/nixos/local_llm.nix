{ lib, ... }:

{
  # Expose this feature as a reusable NixOS module within your flake
  flake.nixosModules.local-llm = { config, pkgs, ... }: {
      services.ollama = {
        enable = true;
        # Enforce the Vulkan build to utilize your Arc 140V
        package = pkgs.ollama-vulkan; 
      };

      # Ensure the necessary Vulkan loaders are present for the GPU
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vulkan-loader
          vulkan-validation-layers
          vulkan-extension-layer
        ];
      };
  };
}
