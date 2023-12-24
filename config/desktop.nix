{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.desktop;
in
{
  options = {
    mlt.desktop = with types; {
      enable = mkEnableOption "desktop";
      gpu = mkOption {
        description = "GPU type installed";
        type = enum [ "amdgpu" "nvidia" ];
        default = "amdgpu";
      };
      gaming = mkEnableOption "gaming";
      printing = mkEnableOption "printing";
      torrent = mkEnableOption "torrents";
      creative = mkEnableOption "creative packages";
      productivity = mkEnableOption "productivity packages";
      email = mkEnableOption "email packages";
      kdeconnect = mkEnableOption "kdeconnect";
      development = mkEnableOption "heavy development tools";
    };
  };

  config = mkMerge [
    (mkIf cfg.productivity {
      environment.systemPackages = with pkgs; [
        kmymoney      # Double-entry accounting platform
        libreoffice   # Office suite
        logseq        # Knowledge management platform
      ];
    })

    (mkIf cfg.email {
      environment.systemPackages = with pkgs; [
        birdtray      # Minimize Thunderbird to tray
        thunderbird   # Email client
      ];
    })

    (mkIf cfg.creative {
      environment.systemPackages = with pkgs; [
        # Image
        gimp          # Image editor
        kdenlive      # Video editor
        krita         # Digital art tool
        # Video
        obs-studio    # Screen recorder
        # Audio
        ardour        # DAW
        lsp-plugins   # Pack of VST plugins
        surge-XT      # Synthesizer VST
        zam-plugins   # Pack of VST plugins by ZamAudio
        # Other
        prusa-slicer  # Slicer for 3D printing
        yed           # Graph drawing tool
      ];
    })

    (mkIf cfg.development {
      environment.systemPackages = with pkgs; [
        vscodium
        insomnia
        jetbrains.idea-ultimate
        jetbrains.clion
        jetbrains.pycharm-professional
        jetbrains.webstorm
      ];
    })

    (mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        # Basic utilities
        ark                     # Archive viewer
        audio-recorder          # Simple audio recorder
        filelight               # Disk space usage viewer
        firefox                 # Browser
        gparted                 # Manage partitions graphically
        kate                    # Text editor
        kcalc                   # Simple calculator
        keepassxc               # Secure local password manager
        kfind                   # Search tool
        okular                  # PDF and image viewer
        psensor                 # View graphs of CPU temperature, etc.
        xdg-desktop-portal-kde  # File picker used by Firefox, Flatpak, and others

        # Media
        calibre     # E-book manager
        mpv         # Media player
        pavucontrol # Audio device manager
        puddletag   # Music tagger
        strawberry  # Music player, forked from Clementine
        syncplay    # Syncronize video watching within a group

        # Sync
        dropbox # Official Dropbox sync client
        insync  # Third-party Google Drive sync client

        # Chat
        discord # Discord client
        hexchat # IRC client
      ];

      # Enable Plasma/Wayland
      services.xserver = {
        enable = true;
        videoDrivers = [ cfg.gpu ];
        layout = "us";
        displayManager = {
          sddm.enable = true;
          defaultSession = "plasmawayland";
        };
        desktopManager.plasma5.enable = true;
      };

      mlt.common.user.additionalExtraGroups = [ "video" "audio" "networkmanager" ];

      # Enable IME
      i18n.inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = [ pkgs.fcitx5-mozc ];
      };

      # Override MPV to include mpris (for media controls integration with DE)
      nixpkgs.overlays = [
        (final: prev: {
          mpv = prev.mpv.override {
            scripts = [ final.mpvScripts.mpris ];
          };
        })
      ];

      # Enable Firefox/Plasma integration
      nixpkgs.config.firefox.nativeMessagingHosts = [ pkgs.plasma-browser-integration ];

      # Install fonts
      fonts.packages = with pkgs; [
        corefonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        nerdfonts
        ipafont
      ];

      # Set default fonts
      fonts.fontconfig.defaultFonts = {
        monospace = [
          "Hack Nerd Font"
          "Noto Sans Mono CJK JP"
        ];

        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK JP"
        ];

        serif = [
          "Noto Serif"
          "Noto Serif CJK JP"
        ];
      };

      # Enable Pipewire
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Enable bluetooth
      hardware.bluetooth = {
        enable = true;
        settings.General.Enable = "Source,Sink,Media,Socket";
      };

      # Enable NoiseTorch for microphone noise removal
      programs.noisetorch.enable = true;
    })

    (mkIf cfg.gaming {
      environment.systemPackages = with pkgs; [
        dolphinEmuMaster
        lutris
        pcsx2
        (prismlauncher.override { jdks = [ jdk8 jdk17 jdk19 ]; })
      ];
      programs.steam.enable = true;
      hardware.opentabletdriver.enable = true;
    })

    (mkIf cfg.printing {
      environment.systemPackages = with pkgs; [
        gnome3.simple-scan
      ];

      # Enable printing.
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          hplip
          epson-escpr
        ];
      };

      # Enable scanning
      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };

      # Add primary user to print/scan groups
      mlt.common.user.additionalExtraGroups = [ "scanner" "lp" ];

      # Enable avahi to help resolve .local addresses
      services.avahi = {
        enable = true;
        nssmdns = true;
      };
    })

    (mkIf cfg.torrent {
      services.mullvad-vpn.enable = true;
      
      environment.systemPackages = with pkgs; [
        deluge
        mullvad-vpn
      ];

      networking = {
        wireguard.enable = true;
        firewall = {
          allowedTCPPortRanges = [ 
            { from = 6881; to = 6999; } # Torrents
          ];
        };
      };
    })

    (mkIf cfg.kdeconnect {
      programs.kdeconnect.enable = true;
    })

    (mkIf (cfg.gpu == "nvidia") {
      environment.systemPackages = with pkgs; [
        nvtop
      ];
    })
  ];
}
