{ config, pkgs, ... }:
let
  personal = import
    (builtins.fetchTarball https://github.com/maxwell-lt/nixpkgs/tarball/2f57ab652f23cb4c77c14b15c931e13cb9e3fc6c)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
  # For discord
  master = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/master)
    { config = config.nixpkgs.config; };
in
{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    kmail kdeApplications.kmail-account-wizard kaddressbook
    krita psensor
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
    #personal.mpv vapoursynth
    (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })
    syncplay deluge pavucontrol
    puddletag obs-studio kdenlive
    calibre cmus
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
    # Enable Japanese IME
    displayManager.sessionCommands = ''
      export XMODIFIERS="@im=fcitx"
      export XMODIFIER="@im=fcitx"
      export GTK_IM_MODULE="fcitx"
      export QT_IM_MODULE="fcitx"
      fcitx &
    '';
  };

  hardware.opengl = {
    driSupport32Bit = true;
    #s3tcSupport = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
}
