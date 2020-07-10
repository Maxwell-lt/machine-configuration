{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
    autoScrub = {
      enable = true;
      interval = "Sat 05:00";
    };
    autoTrim = {
      enable = true;
      interval = "Sat 05:00";
    };
  };
}