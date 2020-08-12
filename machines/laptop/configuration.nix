{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/zfs.nix
      ../../modules/common.nix
      ../../modules/desktop.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "f2fb5ec7";
    hostName = "nix-portable-omega";
  };

  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlp41s0.useDHCP = true;

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
