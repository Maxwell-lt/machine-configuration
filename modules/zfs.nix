{ config, pkgs, lib, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  services.zfs = {
    autoSnapshot = {
      enable = lib.mkDefault false;
      flags = "-k -p --utc";
    };
    autoScrub = {
      enable = true;
      interval = "Sat 05:00";
    };
    trim = {
      enable = true;
      interval = "Sat 05:00";
    };
  };

  virtualisation.podman.extraPackages = [ pkgs.zfs ];
}
