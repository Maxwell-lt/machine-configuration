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

  # Don't change this value from 25.05!
  system.stateVersion = "25.05"; # Did you read the comment?
}
