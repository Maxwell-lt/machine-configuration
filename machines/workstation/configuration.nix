{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  mlt = {
    common = {
      enable = true;
      media = true;
      containers = true;
      user = {
        enable = true;
        password = true;
        additionalExtraGroups = [ "adbusers" ];
      };
      java = {
        enable = true;
        version = "21";
      };
    };
    docker.enable = false;
    desktop = {
      enable = true;
      gpu = "modesetting"; # recommended for AMD drivers over amdgpu
      gaming = true;
      productivity = true;
      email = true;
      creative = true;
      torrent = true;
      printing = true;
      kdeconnect = true;
      development = true;
      tex = true;
    };
    openrgb = {
      enable = true;
      motherboard = "amd";
    };
    vm.enable = true;
    zfs.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "8192";
    }
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "16384";
    }
  ];

  environment.systemPackages = with pkgs; [
    zoom-us
  ];

  virtualisation.waydroid.enable = true;

  networking.networkmanager.enable = true;

  # Disable HDMI audio output (gets set to the default on reboot/sleep/unlock)
  boot.blacklistedKernelModules = [
    "snd_hda_intel"
    "snd_hda_codec_hdmi"
  ];

  services.coder = {
    enable = true;
    accessUrl = "https://coder.maxwell-lt.dev";
    listenAddress = "10.100.0.5:3000";
  };
  # Needed for coder
  services.postgresql = {
    package = pkgs.postgresql;
  };
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 3000 ];

  # Setup Wireguard client
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.5/24" ];
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
    wg1 = {
      ips = [ "10.171.0.5/24" ];
      privateKeyFile = "/root/private";
      peers = [
        {
          publicKey = "bKpFQfksgXYgL+5u1WjA719quJPiZVxShDBJzmIdlE8=";
          allowedIPs = [ "10.171.0.1/32" ];
          endpoint = "brage.info:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.zrepl = {
    enable = true;
    settings = {
      global = {
        monitoring = [
          {
            listen = ":9811";
            type = "prometheus";
          }
        ];
      };
      jobs = [
        {
          connect = {
            address = "158.69.224.168:8550";
            ca = "/var/spool/zrepl/ca.crt";
            cert = "/var/spool/zrepl/maxwell-nixos.crt";
            key = "/var/spool/zrepl/maxwell-nixos.key";
            server_cn = "library-of-babel";
            type = "tls";
          };
          filesystems = {
            "rpool/safe<" = true;
          };
          name = "rpool_push";
          pruning = {
            keep_receiver = [
              {
                grid = "24x1h | 30x1d | 12x30d";
                regex = "^zrepl_";
                type = "grid";
              }
              {
                type = "last_n";
                count = 2;
                regex = "^zrepl_";
              }
            ];
            keep_sender = [
              {
                type = "not_replicated";
              }
              {
                grid = "1x3h(keep=all) | 24x1h | 3x1d";
                regex = "^zrepl_";
                type = "grid";
              }
            ];
          };
          snapshotting = {
            interval = "10m";
            prefix = "zrepl_";
            type = "periodic";
          };
          type = "push";
          send = {
            encrypted = true;
          };
        }
      ];
    };
  };

  services.flatpak.enable = true;

  programs.adb.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "79eefeea";
    hostName = "maxwell-nixos";
  };

  # Allow containers to access external network
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "enp16s0";
  };

  networking.useDHCP = false;
  networking.interfaces.enp16s0.useDHCP = true;
  networking.interfaces.wlp17s0.useDHCP = false;

  networking.firewall.allowedTCPPorts = [
    # Avoid 30 second wait before login prompt when connecting to Lutron SmartBridge using Telnet: https://forums.lutron.com/showthread.php/3031-30-second-Telnet-Login-Delay
    113
    # zrepl prometheus exporter
    9811

    # Satisfactory
    5222 6666
    
    # Dynmap
    8123
    # Minecraft
    25565
    # Minecraft web site
    9990
  ];

  networking.firewall.allowedUDPPorts = [
    # Satisfactory
    5222 6666
    # WG
    51820
  ];

  networking.firewall.allowedUDPPortRanges = [
    # Satisfactory
    { from = 7777; to = 9999; }
  ];

  networking.firewall.allowedTCPPortRanges = [
    # Satisfactory
    { from = 7777; to = 9999; }
  ];
  
  # Needed to use erisia/builder
  nix.settings.sandbox = "relaxed";

  # Switch Pro Controller udev rules
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:057E:2009.*", MODE="0666"
  '';

  users.users.minecraft = {
    description  = "Minecraft user account";
    isNormalUser = true;
    shell = pkgs.zsh;
    createHome = true;
    linger = true;
    packages = with pkgs; [
      tmux
      kitty
    ];
  };
  
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."serverpack" = {
      serverName = "10.100.0.5";
      listen = [{
        addr = "10.100.0.5";
        port = 9990;
      }];
      locations."/" = {
        root = "/srv/minecraft";
      };
      extraConfig = ''
        autoindex on;
      '';
    };
  };

  fileSystems."/srv/minecraft" = {
    device = "/home/minecraft/web";
    depends = ["/home/minecraft/web"];
    options = ["bind"];
  };

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
