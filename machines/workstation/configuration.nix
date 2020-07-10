# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/zfs.nix
      ../../modules/common.nix
      ../../modules/desktop.nix
      ../../modules/nvidia.nix
    ];

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

