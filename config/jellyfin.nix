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
      enable = true;
      settings = {
        download-dir = "/mnt/media/staging/torrents";
        watch-dir-enabled = true;
        watch-dir = "/mnt/media/staging/torrent-watch";
      };
    };

    systemd.services.transmission.vpnconfinement = {
      enable = true;
      vpnnamespace = "wg";
    };

    mlt.common.user.additionalExtraGroups = [ "jellyfin" ];

    sops.secrets."wg-quick.conf" = {
      sopsFile = ../secrets/wireguard.yaml;
      path = "/var/lib/nixarr/wg-quick.conf";
    };

    vpnnamespaces."wg" = {
      enable = true;
      wireguardConfigFile = config.sops.secrets."wg-quick.conf".path;
    };
  };
}
