{ config, pkgs, ... }:

{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    kmail kdeApplications.kmail-account-wizard kaddressbook
    # Games
    steam (steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ];}).run
    jdk8 multimc dolphinEmuMaster lutris
    # Browsers
    firefox chromium
    xdg-desktop-portal-kde
    plasma-browser-integration
    # Passwords and sync
    keepassxc insync dropbox
    # Media
    (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })
    syncplay deluge pavucontrol
    puddletag obs-studio kdenlive
    calibre
    # Chat
    discord
    hexchat
    # Development
    jetbrains.idea-ultimate jetbrains.clion
    jetbrains.pycharm-professional jetbrains.webstorm
    vscodium atom
    # Connectivity
    kdeconnect
    # VM dependencies
    kvm qemu libvirt bridge-utils virt-manager
    virt-viewer spice-vdagent
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    mpv = pkgs.mpv-unwrapped.override {
      vapoursynthSupport = true;
    };
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
    support32Bit = true;
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
  };

  hardware.opengl = {
    driSupport32Bit = true;
    #s3tcSupport = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
}
