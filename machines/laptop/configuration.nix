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
    desktop = {
      enable = true;
      printing = true;
      productivity = true;
    };
    zfs.enable = true;
  };

  sops = {
    defaultSopsFile = ../../secrets/wifi.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."wireless.env" = { };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "f2fb5ec7";
    hostName = "nix-portable-omega";
  };

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.wireless = {
    environmentFile = config.sops.secrets."wireless.env".path;
    enable = false;
    networks = {
      "@home_uuid@" = {
        psk = "@home_psk@";
        priority = 40;
      };
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Setup Wireguard client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.4/24" ];

    privateKeyFile = "/root/private";

    peers = [
      {
        publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";

        allowedIPs = [ "10.100.0.1" ];

        endpoint = "158.69.224.168:51820";

        persistentKeepalive = 25;
      }
    ];
  };

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

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
