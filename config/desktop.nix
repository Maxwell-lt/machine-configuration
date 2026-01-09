{ config, lib, pkgs, inputs, ... }:

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
        type = nullOr (enum [ "amdgpu" "nvidia" "modesetting" ]);
        default = null;
      };
      gaming = mkEnableOption "gaming";
      printing = mkEnableOption "printing";
      torrent = mkEnableOption "torrents";
      creative = mkEnableOption "creative packages";
      productivity = mkEnableOption "productivity packages";
      email = mkEnableOption "email packages";
      kdeconnect = mkEnableOption "kdeconnect";
      development = mkEnableOption "heavy development tools";
      tex = mkEnableOption "TeX tools";
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
        kdePackages.kdenlive      # Video editor
        krita         # Digital art tool
        # Video
        obs-studio    # Screen recorder
        # Audio
        ardour        # DAW
        lsp-plugins   # Pack of VST plugins
        #surge-XT      # Synthesizer VST
        zam-plugins   # Pack of VST plugins by ZamAudio
        # 3D Printing
        prusa-slicer  # Slicer
        freecad       # CAD (traditional)
        openscad      # CAD (text-based modeling)
        # Other
        plantuml-c4   # UML renderer, with support for C4 diagrams
        yed           # Graph drawing tool
      ];
    })

    (mkIf cfg.development {
      environment.systemPackages = with pkgs; [
        vscodium
        insomnia
        jetbrains-toolbox
      ];
    })

    (mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        # Basic utilities
        kdePackages.ark                     # Archive viewer
        #audio-recorder          # Simple audio recorder
        kdePackages.dolphin                 # KDE file manager
        kdePackages.dolphin-plugins
        kdePackages.baloo-widgets
        kdePackages.baloo
        feh                     # Simple file viewer
        kdePackages.filelight               # Disk space usage viewer
        filezilla               # FTP client
        firefox                 # Browser
        (flameshot.override {enableWlrSupport = true;}) # Screenshot tool
        gparted                 # Manage partitions graphically
        kdePackages.kate                    # Text editor
        kdePackages.kcalc                   # Simple calculator
        keepassxc               # Secure local password manager
        kdePackages.kfind                   # Search tool
        kdePackages.okular                  # PDF and image viewer
        wlr-randr               # Configure monitors on Wayland
        kdePackages.xdg-desktop-portal-kde  # File picker used by Firefox, Flatpak, and others

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

      xdg = {
        mime.enable = true;
        menus.enable = true;
        portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-hyprland
            pkgs.xdg-desktop-portal-wlr
            pkgs.xdg-desktop-portal-gtk
            pkgs.kdePackages.xdg-desktop-portal-kde
          ];
        };
      };

      # Enable Plasma/Wayland
      services.xserver = {
        enable = true;
        videoDrivers = mkIf (cfg.gpu != null) [ cfg.gpu ];
        xkb.layout = "us";
      };
      services.displayManager = {
        sddm.enable = false;
        defaultSession = "hyprland";
      };
      services.desktopManager.plasma6.enable = false;

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          };
        };
      };

      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal"; # Without this errors will spam on screen
        # Without these bootlogs will spam on screen
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };

      mlt.common.user.additionalExtraGroups = [ "video" "audio" "networkmanager" ];

      # Enable IME
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = [ pkgs.fcitx5-mozc ];
          waylandFrontend = true;
        };
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
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.hack
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
        wireplumber.configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-bluez-config.conf" ''
            monitor.bluez.properties = {
              bluez5.enable-hw-volume = false
              bluez5.hfphsp-backend = "none"
              bluez5.a2dp.ldac.quality = "hq"
            }
          '')
        ];
      };

      # Enable bluetooth
      hardware.bluetooth = {
        enable = true;
        settings.General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };

      # Enable NoiseTorch for microphone noise removal
      programs.noisetorch.enable = true;

      # Experimental: enable Hyprland
      programs.hyprland = {
        enable = true;
      };
      security.pam.services.swaylock = {};
    })

    (mkIf cfg.gaming {
      environment.systemPackages = with pkgs; [
        dolphin-emu
        ryubing
        lutris
        pcsx2
        (prismlauncher.override {
          jdks = [ jdk8 jdk17 jdk21 jdk25 ];
        })
        umu-launcher
        (callPackage ../pkgs/itgmania-bin {})
        (callPackage ../pkgs/outfox {})
      ];
      programs.steam.enable = true;
      hardware.opentabletdriver.enable = true;
    })

    (mkIf cfg.printing {
      environment.systemPackages = with pkgs; [
        simple-scan
      ];

      # Enable printing.
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          hplip
          epson-escpr
          brlaser
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
        nssmdns4 = true;
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

    (mkIf cfg.tex {
      environment.systemPackages = with pkgs; [
        texliveFull
        texstudio
      ];
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
