{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.jellyfin;
in
{
  options = {
    mlt.jellyfin = {
      enable = mkEnableOption "jellyfin";
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    services.transmission = {
      enable = false;
      settings = {
        download-dir = "/mnt/media/staging/torrents";
        watch-dir-enabled = true;
        watch-dir = "/mnt/media/staging/torrent-watch";
      };
    };

    mlt.common.user.additionalExtraGroups = [ "jellyfin" ];
  };
}
