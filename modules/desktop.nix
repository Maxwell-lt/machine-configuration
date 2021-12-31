{ config, pkgs, lib, ... }:
{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    krita psensor kcalc gnome3.simple-scan
    # KMail and friends
    plasma5Packages.kmail-account-wizard kaddressbook plasma5Packages.kleopatra plasma5Packages.pim-data-exporter
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
    #discord = pkgs.discord.overrideAttrs (old: {
    #  src = pkgs.fetchurl {
    #    url = "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz";
    #    sha256 = "0pn2qczim79hqk2limgh88fsn93sa8wvana74mpdk5n6x5afkvdd";
    #  };
    #});
  };

  # Enable IME
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  nixpkgs.config.firefox = {
    enablePlasmaBrowserIntegration = true;
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
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
      epson-escpr
    ];
  };

  # Network scanning
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };
  users.users.maxwell.extraGroups = [ "scanner" "lp" ];
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    #package = pkgs.pulseaudioFull;
    #extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable bluetooth.
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    settings.General.Enable = "Source,Sink,Media,Socket";
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
