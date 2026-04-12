{ lib, ... }:

{
  # Expose this feature as a reusable NixOS module within your flake
  flake.nixosModules.local-llm =
    { config, pkgs, ... }:
    {
      virtualisation.containers.enable = true;
      virtualisation.podman = {
        enable = true;
        dockerCompat = true; # Allows you to run standard `docker` commands in terminal
        defaultNetwork.settings.dns_enabled = true;
      };

      # Tell NixOS to use Podman for OCI containers
      virtualisation.oci-containers.backend = "podman";

      virtualisation.oci-containers.containers = {

        # CONTAINER 1: LocalAI (Actively Maintained Intel SYCL Backend)
        local-ai = {
          image = "quay.io/go-skynet/local-ai:latest-gpu-intel";
          volumes = [
            # Replace "yourusername" with your actual Linux username
            "/srv/ai-models:/models"
            "/srv/localai-data:/data"
            "/srv/backends:/backends"
            "localai_configuration:/configuration"
          ];
          extraOptions = [
            "--device=/dev/dri"
            # Still crucial for Intel iGPUs/Lunar Lake to prevent memory fragmentation
            "--shm-size=16g"
          ];
          ports = [ "8080:8080" ];
        };

        # CONTAINER 2: The Search Engine (SearXNG)
        searxng = {
          image = "searxng/searxng:latest";
          environment = {
            "SEARXNG_URL" = "http://searxng:8080";
          };
        };

        # CONTAINER 3: Open WebUI
        open-webui = {
          image = "ghcr.io/open-webui/open-webui:main";
          volumes = [
            "open-webui_data:/app/backend/data"
          ];
          environment = {
            # Tell Open WebUI to bypass Ollama and use LocalAI's OpenAI-compatible endpoint
            "OPENAI_API_BASE_URL" = "http://local-ai:8080/v1";
            "OPENAI_API_KEY" = "dummy-key"; # Required by standard API, can be any string

            # Hook up the local web search
            "WEB_SEARCH_ENGINE" = "searxng";
            "SEARXNG_QUERY_URL" = "http://searxng:8080/search?format=json";
          };
          ports = [ "3000:8080" ];
          dependsOn = [
            "local-ai"
            "searxng"
          ];
        };

      };
    };
}
