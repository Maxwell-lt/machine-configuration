{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/common.nix
  ];

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        "home-assistant" = {
          image = "homeassistant/home-assistant:stable";
          dependsOn = [ "postgres-hass" ];
          volumes = [
            "/srv/container/hass-config:/config"
            "/etc/localtime:/etc/localtime:ro"
          ];
          autoStart = true;
          ports = [
            "8123:8123"
          ];
        };
        "postgres-hass" = {
          image = "postgres:13.3";
          volumes = [
            "/srv/container/postgres-hass:/var/lib/postgresql/data"
            "/etc/localtime:/etc/localtime:ro"
          ];
          autoStart = true;
          ports = [
            "5432:5432"
          ];
          environment = let secrets = import ../../secrets/postgres.nix; in {
            POSTGRES_USER = "hass";
            POSTGRES_PASSWORD = secrets.postgresPass;
          };
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      8123  # Home Assistant
      113   # Open IDENT port so that Lutron bridge won't spend 30 seconds backing off from it
    ];
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

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
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
