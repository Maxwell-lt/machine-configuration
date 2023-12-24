{ config, pkgs, lib, ... }:

{
  mlt.common = {
    enable = true;
    user.enable = true;
    containers = true;
  };

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        "home-assistant" = {
          image = "homeassistant/home-assistant:2022.4.3";
          dependsOn = [ "postgres-hass" ];
          volumes = [
            "/srv/container/home-assistant:/config"
            "/etc/localtime:/etc/localtime:ro"
          ];
          autoStart = true;
          extraOptions = [ "--pod=home-assistant-pod" ];
        };
        "postgres-hass" = {
          image = "postgres:14.2";
          volumes = [
            "/srv/container/postgres-home-assistant:/var/lib/postgresql/data"
            "/etc/localtime:/etc/localtime:ro"
          ];
          autoStart = true;
          environment = let secrets = import ../../secrets/postgres.nix; in {
            POSTGRES_USER = "hass";
            POSTGRES_PASSWORD = secrets.postgresPass;
          };
          extraOptions = [ "--pod=home-assistant-pod" ];
        };
      };
    };
  };

  systemd.services.create-hass-pod = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "podman-postgres-hass.service"
      "podman-home-assistant.service"
    ];
    script = with pkgs; ''
      ${podman}/bin/podman pod exists home-assistant-pod || \
        ${podman}/bin/podman pod create --name home-assistant-pod -p '0.0.0.0:8123:8123 --network bridge'
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [
      8123  # Home Assistant
      113   # Open IDENT port so that Lutron bridge won't spend 30 seconds backing off from it
    ];
    allowedUDPPorts = [
      51820 # Wireguard
    ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.3/24" ];
      privateKeyFile = "/root/wireguard-keys/private";
      peers = [
        {
          publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";
          allowedIPs = [ "10.100.0.1" ];
          endpoint = "158.69.224.168:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
  };

  #boot.loader.raspberryPi = {
  #  enable = true;
  #  version = 4;
  #};
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkForce false;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "rpi4-nixos";
    networkmanager = {
      enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
  ];

  nix = {
    autoOptimiseStore = true;
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  system.stateVersion = "21.03";
  #swapDevices = [ { device = "/swapfile"; size = 3072; } ];
}
