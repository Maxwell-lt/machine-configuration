# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "ssdpool/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "ssdpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/20B0-FAC4";
      fsType = "vfat";
    };

  fileSystems."/ssdpool" =
    { device = "ssdpool";
      fsType = "zfs";
    };

  fileSystems."/rustpool" =
    { device = "rustpool";
      fsType = "zfs";
    };

  fileSystems."/mnt/media" =
    { device = "rustpool/media";
      fsType = "zfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}