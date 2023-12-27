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

    mlt.common.user.additionalExtraGroups = [ "jellyfin" ];
  };
}
