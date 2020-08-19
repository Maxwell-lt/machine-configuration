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
      snapshotting.interval = 10;
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

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
