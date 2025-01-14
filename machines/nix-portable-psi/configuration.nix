{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  mlt = {
    common = {
      enable = true;
      media = true;
      user = {
        enable = true;
        password = true;
      };
      containers = true;
      java = {
        enable = true;
        version = "21";
      };
    };
    desktop = {
      enable = true;
      printing = true;
      productivity = true;
    };
    docker.enable = true;
    zfs.enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "7d63600d";
    hostName = "nix-portable-psi";
  };

  environment.systemPackages = with pkgs; [
    # SDR
    rtl-sdr-osmocom
    sdrangel
    redisinsight
    dump1090
    direwolf
    rtl_433

    jetbrains.datagrip

    jetbrains.idea-ultimate

    maven
    gradle

    burpsuite

    vscode-fhs
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Setup Wireguard client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.7/24" ];

    privateKeyFile = "/root/private";

    peers = [
      {
        publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";

        allowedIPs = [ "10.100.0.0/24" ];

        endpoint = "158.69.224.168:51820";

        persistentKeepalive = 25;
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  #services.zrepl = {
  #  enable = true;
  #  push.rpool = {
  #    serverCN = "library-of-babel";
  #    sourceFS = "rpool";
  #    exclude = [
  #      "rpool/root/nixos"
  #    ];
  #    targetHost = "158.69.224.168";
  #    targetPort = 8551;
  #    snapshotting.interval = 10;
  #  };
  #};

  programs.light = {
    enable = true;
    brightnessKeys = {
      enable = true;
      step = 5;
    };
  };

  services.redis.servers."" = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';
    extensions = ps: with ps; [ postgis ];
    identMap = ''
      superuser_map    maxwell    postgres
    '';
  };

  # nix-ld configuration copied from https://nixos.wiki/wiki/Jetbrains_Tools
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL_image
    SDL_mixer
    SDL_ttf
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    clang
    cups
    curlWithGnuTls
    dbus
    dbus-glib
    desktop-file-utils
    e2fsprogs
    expat
    flac
    fontconfig
    freeglut
    freetype
    fribidi
    fuse
    fuse3
    gdk-pixbuf
    glew110
    glib
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk2
    harfbuzz
    icu
    keyutils.lib
    libGL
    libGLU
    libappindicator-gtk2
    libcaca
    libcanberra
    libcap
    libclang.lib
    libdbusmenu
    libdrm
    libgcrypt
    libgpg-error
    libidn
    libjack2
    libjpeg
    libmikmod
    libogg
    libpng12
    libpulseaudio
    librsvg
    libsamplerate
    libthai
    libtheora
    libtiff
    libudev0-shim
    libusb1
    libuuid
    libvdpau
    libvorbis
    libvpx
    libxcrypt-legacy
    libxkbcommon
    libxml2
    lld
    mesa
    nspr
    nss
    openssl
    p11-kit
    pango
    pixman
    python3
    speex
    stdenv.cc.cc
    tbb
    udev
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libpciaccess
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
    xz
    zlib
  ];

  # Don't change this value from 25.05!
  system.stateVersion = "25.05"; # Did you read the comment?
}
