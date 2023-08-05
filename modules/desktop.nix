{ config, pkgs, lib, ... }:
{

  imports = [ ./mullvad.nix ];
  environment.systemPackages = with pkgs; [
    # UI utils
    kate ark okular filelight audio-recorder
    libreoffice gparted yed
    krita psensor kcalc gnome3.simple-scan
    logseq prusa-slicer
    # KMail and friends
    plasma5Packages.kmail-account-wizard kaddressbook plasma5Packages.kleopatra plasma5Packages.pim-data-exporter
    thunderbird birdtray kfind
    # Games
    (steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ];}).run
    dolphinEmuMaster lutris pcsx2
    (prismlauncher.override { jdks = [ jdk jdk8 jdk19 ]; })
    # Browsers
    firefox
    xdg-desktop-portal-kde
    plasma-browser-integration
    # Passwords and sync
    keepassxc dropbox
    insync
    # Media
    mpv
    #mpv vapoursynth
    syncplay deluge pavucontrol
    puddletag 
    kdenlive
    obs-studio
    calibre cmus
    clementine
    picard
    # Chat
    discord
    hexchat
    # Development
    jetbrains.idea-ultimate jetbrains.clion
    jetbrains.pycharm-professional jetbrains.webstorm
    vscodium atom postman insomnia
    # Connectivity
    kdeconnect
    # VM dependencies
    qemu_kvm qemu libvirt bridge-utils virt-manager
    virt-viewer spice-vdagent
  ];

  fonts.packages = with pkgs; [
    powerline-fonts corefonts
    noto-fonts noto-fonts-cjk
    noto-fonts-emoji noto-fonts-extra
    nerdfonts ipafont
    
  ];

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

  programs.steam.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      mpv = prev.mpv.override {
        scripts = [ final.mpvScripts.mpris ];
      };
      #mpv = (prev.mpv-unwrapped.override {
      #  vapoursynthSupport = true;
      #  vapoursynth = final.vapoursynth;
      #}).overrideAttrs (old: rec {
      #  wafConfigureFlags = old.wafConfigureFlags ++ ["--enable-vapoursynth"];
      #});
      #discord = prev.discord.overrideAttrs (old: {
      #  src = final.fetchurl {
      #    url = "https://dl.discordapp.net/apps/linux/0.0.17/discord-0.0.17.tar.gz";
      #    sha256 = "058k0cmbm4y572jqw83bayb2zzl2fw2aaz0zj1gvg6sxblp76qil";
      #  };
      #});
      #insync-v3 = prev.insync-v3.overrideAttrs (old: {
      #  src = final.fetchurl {
      #    url = "https://cdn.insynchq.com/builds/linux/insync_3.7.11.50381-focal_amd64.deb";
      #    sha256 = "sha256-W4YUjQ8VdU+m5DwPlokO0i/mKWOi/1vN79ZmMJk9dZM=";
      #  };
      #});
    })
  ];

  # Enable IME
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
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
