{ config, pkgs, lib, ... }:
let
  personal = import
    (builtins.fetchTarball https://github.com/maxwell-lt/nixpkgs/tarball/2f57ab652f23cb4c77c14b15c931e13cb9e3fc6c)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
  # For discord
  master = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/master)
    { config = config.nixpkgs.config; };
  pinnedKdeConnect = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/6b6f6808318d4a445870048d1175fcb55b1b69aa)
    { config = config.nixpkgs.config; };
in
{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    krita psensor kcalc
    # KMail and friends
    kmail kdeApplications.kmail-account-wizard kaddressbook kdeApplications.kleopatra kdeApplications.pim-data-exporter
    thunderbird birdtray
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
    #personal.mpv vapoursynth
    (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })
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
    vscodium atom
    # Connectivity
    pinnedKdeConnect.kdeconnect
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
  };

  # Enable IME
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  nixpkgs.config.firefox = {
    enablePlasmaBrowserIntegration = true;
    # Broken for now:
    #enableAdobeFlash = true;
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
