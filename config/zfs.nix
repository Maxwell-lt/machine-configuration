{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.zfs;
in
{
  options = {
    mlt.zfs = {
      enable = mkEnableOption "zfs";
    };
  };

  config = mkIf cfg.enable {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.requestEncryptionCredentials = true;

    services.zfs = {
      autoSnapshot = {
        enable = lib.mkDefault false;
        flags = "-k -p --utc";
      };
      autoScrub = {
        enable = true;
        interval = "daily";
      };
      trim = {
        enable = true;
        interval = "weekly";
      };
    };

    virtualisation.podman.extraPackages = [ pkgs.zfs ];
  };
}
