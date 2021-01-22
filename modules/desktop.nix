{ config, pkgs, lib, ... }:
{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    krita psensor kcalc
    # KMail and friends
    kmail kdeApplications.kmail-account-wizard kaddressbook kdeApplications.kleopatra kdeApplications.pim-data-exporter
    thunderbird birdtray kfind
    # Games
    (steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ];}).run
    jdk8 multimc dolphinEmuMaster lutris pcsx2
    # Browsers
    firefox
    xdg-desktop-portal-kde
    plasma-browser-integration
    # Passwords and sync
    keepassxc insync dropbox
    # Media
    (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })
    #mpv vapoursynth
    syncplay deluge pavucontrol
    puddletag kdenlive
    obs-studio
    calibre cmus
    # Chat
    discord
    hexchat
    # Development
    jetbrains.idea-ultimate jetbrains.clion
    jetbrains.pycharm-professional jetbrains.webstorm
    vscodium atom postman
    # Connectivity
    kdeconnect
    # VM dependencies
    kvm qemu libvirt bridge-utils virt-manager
    virt-viewer spice-vdagent
  ];

  programs.steam.enable = true;

  nixpkgs.config.packageOverrides = pkgs: rec {
    mpv = (pkgs.mpv-unwrapped.override {
      vapoursynthSupport = true;
      vapoursynth = pkgs.vapoursynth;
    }).overrideAttrs (old: rec {
      wafConfigureFlags = old.wafConfigureFlags ++ ["--enable-vapoursynth"];
    });
    discord = pkgs.discord.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://dl.discordapp.net/apps/linux/0.0.13/discord-0.0.13.tar.gz";
        sha256 = "0d5z6cbj9dg3hjw84pyg75f8dwdvi2mqxb9ic8dfqzk064ssiv7y";
      };
    });
    flashplayer = pkgs.flashplayer.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://fpdownload.adobe.com/get/flashplayer/pdc/32.0.0.465/flash_player_npapi_linux.x86_64.tar.gz";
        sha256 = "0dbccg7ijlr9wdjkh6chbw0q1qchycbi1a313hrrc613k3djw3x9";
      };
    });
  };

  # Enable IME
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  nixpkgs.config.firefox = {
    enablePlasmaBrowserIntegration = true;
    # Broken for now:
    enableAdobeFlash = true;
  };

  virtualisation.libvirtd.enable = true;

  # Open up ports
  networking.firewall = {
    allowedTCPPortRanges = [ 
      { from = 6881; to = 6999; } # Torrents
      { from = 1714; to = 1764; } # KDEConnect
    ];
    allowedUDPPortRanges = [      
      { from = 1714; to = 1764; } # KDEConnect
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  # Enable bluetooth.
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    config.General.Enable = "Source,Sink,Media,Socket";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    # Enable Japanese IME
    displayManager.sessionCommands = ''
      export XMODIFIERS="@im=fcitx"
      export XMODIFIER="@im=fcitx"
      export GTK_IM_MODULE="fcitx"
      export QT_IM_MODULE="fcitx"
      fcitx &
    '';
  };
}
