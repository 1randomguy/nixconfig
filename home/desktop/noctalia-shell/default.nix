{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.desktop.noctalia-shell;
  settings = if cfg.laptop then {
    bar = {
      density = "default";
      backgroundOpacity = 0.77;
      capsuleOpacity = 0.8;
      floating = true;
      marginHorizontal = 0.32;
      marginVertical = 0.23;
      showCapsule = true;
      widgets = {
          center = [
              {
                  id = "Clock";
                  customFont = "";
                  formatHorizontal = "HH:mm ddd; MMM dd";
                  formatVertical = "HH mm - dd MM";
                  useCustomFont = false;
                  usePrimaryColor = true;
              }
              {
                  id = "NotificationHistory";
                  hideWhenZero = true;
                  showUnreadBadge = true;
              }
          ];
          left = [
              {
                  id = "Workspace";
                  characterCount = 2;
                  hideUnoccupied = false;
                  labelMode = "none";
              }
              {
                  id = "SystemMonitor";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskUsage = true;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  usePrimaryColor = false;
              }
              {
                  id = "MediaMini";
                  hideMode = "hidden";
                  hideWhenIdle = false;
                  maxWidth = 160;
                  scrollingMode = "hover";
                  showAlbumArt = false;
                  showArtistFirst = true;
                  showVisualizer = false;
                  useFixedWidth = false;
                  visualizerType = "linear";
              }
          ];
          right = [
              {
                  id = "Tray";
                  blacklist = [ ];
                  colorizeIcons = false;
                  drawerEnabled = true;
                  pinned = [ ];
              }
              {
                  displayMode = "onhover";
                  id = "KeyboardLayout";
              }
              {
                  displayMode = "onhover";
                  id = "Bluetooth";
              }
              {
                  displayMode = "onhover";
                  id = "Volume";
              }
              {
                  displayMode = "onhover";
                  id = "Brightness";
              }
              {
                  displayMode = "alwaysShow";
                  id = "Battery";
                  warningThreshold = 30;
              }
              {
                  id = "ControlCenter";
                  icon = "noctalia";
                  colorizeDistroLogo = false;
                  customIconPath = "";
                  useDistroLogo = false;
              }
              {
                  id = "SessionMenu";
                  colorName = "error";
              }
          ];
      };
    };
    colorSchemes = {
      predefinedScheme = "Catppuccin";
    };
    dock.enabled = false;
    general = {
      avatarImage = "/home/bene/Nextcloud/Photos/DiscordPB/takumi.jpg";
      #enableShadows = false;
      shadowDirection = "overhead";
      radiusRatio = 0.45;
    };
    ui = {
      fontDefault = "Adwaita Sans";
      fontFixed = "JetBrains Mono";
      panelsAttachedToBar = false;
      settingsPanelAttachToBar = false;
    };
    wallpaper.defaultWallpaper = cfg.wallpaper;
    location = {
      name = "Darmstadt";
      showWeekNumberInCalendar = false;
    };
  } 
  else {
    bar = {
      density = "default";
      backgroundOpacity = 0.77;
      capsuleOpacity = 0.8;
      floating = true;
      marginHorizontal = 0.32;
      marginVertical = 0.23;
      showCapsule = true;
      widgets = {
          center = [
              {
                  id = "Clock";
                  customFont = "";
                  formatHorizontal = "HH:mm ddd; MMM dd";
                  formatVertical = "HH mm - dd MM";
                  useCustomFont = false;
                  usePrimaryColor = true;
              }
              {
                  id = "NotificationHistory";
                  hideWhenZero = true;
                  showUnreadBadge = true;
              }
          ];
          left = [
              {
                  id = "Workspace";
                  characterCount = 2;
                  hideUnoccupied = false;
                  labelMode = "none";
              }
              {
                  id = "SystemMonitor";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskUsage = true;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  usePrimaryColor = false;
              }
              {
                  id = "MediaMini";
                  hideMode = "hidden";
                  hideWhenIdle = false;
                  maxWidth = 160;
                  scrollingMode = "hover";
                  showAlbumArt = false;
                  showArtistFirst = true;
                  showVisualizer = false;
                  useFixedWidth = false;
                  visualizerType = "linear";
              }
          ];
          right = [
              {
                  id = "Tray";
                  blacklist = [ ];
                  colorizeIcons = false;
                  drawerEnabled = true;
                  pinned = [ ];
              }
              {
                  displayMode = "onhover";
                  id = "KeyboardLayout";
              }
              {
                  displayMode = "onhover";
                  id = "Bluetooth";
              }
              {
                  displayMode = "onhover";
                  id = "Volume";
              }
              {
                  id = "ControlCenter";
                  icon = "noctalia";
                  colorizeDistroLogo = false;
                  customIconPath = "";
                  useDistroLogo = false;
              }
              {
                  id = "SessionMenu";
                  colorName = "error";
              }
          ];
      };
    };
    colorSchemes = {
      predefinedScheme = "Catppuccin";
    };
    dock.enabled = false;
    general = {
      avatarImage = "/home/bene/Nextcloud/Photos/DiscordPB/takumi.jpg";
      #enableShadows = false;
      shadowDirection = "overhead";
      radiusRatio = 0.45;
    };
    ui = {
      fontDefault = "Adwaita Sans";
      fontFixed = "JetBrains Mono";
      panelsAttachedToBar = false;
      settingsPanelAttachToBar = false;
    };
    wallpaper = {
      enabled = true;
      defaultWallpaper = cfg.wallpaper;
      overviewEnabled = true;
    };
    location = {
      name = "Darmstadt";
      showWeekNumberInCalendar = false;
    };
  } ;

in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.desktop.noctalia-shell = {
    enable = lib.mkEnableOption "enable noctalia-shell desktop config";
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables Laptop specific entries: Battery and Brightness";
    };
    wallpaper = lib.mkOption {
      type = lib.types.str;
      default = "/home/bene/Nextcloud/Photos/Wallpaper/catppuccin-wallpapers-main/landscapes/yosemite.png";
      description = "Path to the picture that you want to use as a wallpaper";
    };
  };

  config = lib.mkIf cfg.enable {
    #home.packages = with pkgs; [ 
    #  inputs.noctalia.packages.${system}.default
    #];

    programs.noctalia-shell = {
      enable = true;
      settings = settings;
    };
  };
}
