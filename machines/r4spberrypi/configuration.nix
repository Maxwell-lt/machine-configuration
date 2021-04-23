{ config, pkgs, lib, ... }:

{
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

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "rpi4-nixos";
    networkmanager = {
      enable = false;
    };
  };

  services.openssh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    gitAndTools.gitFull
   ];

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.root = {
      password = "apassword";
    };
    users.maxwell = {
      isNormalUser = true;
      password = "apassword";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
  };

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
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
