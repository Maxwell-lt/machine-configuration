{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/zfs.nix
      ../../modules/common.nix
      ../../modules/desktop.nix
      ../../modules/nvidia.nix
      ../../modules/zrepl.nix
    ];

  environment.systemPackages = with pkgs; [
    # Modify RGB configuration
    openrgb i2c-tools
    # Cheating the system
    flatpak
  ];

  services.zrepl = {
    enable = true;
    push.rpool = {
      serverCN = "library-of-babel";
      sourceFS = "rpool/safe";
      targetHost = "158.69.224.168";
      targetPort = 8551;
      snapshotting.interval = 60;
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

  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlp41s0.useDHCP = true;

  # Needed to use erisia/builder
  nix.useSandbox = "relaxed";

  # Switch Pro Controller udev rules
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:057E:2009.*", MODE="0666"
  '';

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
