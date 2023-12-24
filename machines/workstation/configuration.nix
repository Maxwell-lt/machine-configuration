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
    };
    docker.enable = true;
    desktop = {
      enable = true;
      gpu = "amdgpu";
      gaming = true;
      productivity = true;
      email = true;
      creative = true;
      torrent = true;
      printing = true;
      kdeconnect = true;
      development = true;
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

  networking.networkmanager.enable = true;

  # Disable HDMI audio output (gets set to the default on reboot/sleep/unlock)
  boot.blacklistedKernelModules = [
    "snd_hda_intel"
    "snd_hda_codec_hdmi"
  ];

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
  networking.interfaces.wlp17s0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    # Avoid 30 second wait before login prompt when connecting to Lutron SmartBridge using Telnet: https://forums.lutron.com/showthread.php/3031-30-second-Telnet-Login-Delay
    113
    # zrepl prometheus exporter
    9811

    # Satisfactory
    5222 6666
  ];

  networking.firewall.allowedUDPPorts = [
    # Satisfactory
    5222 6666
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

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
