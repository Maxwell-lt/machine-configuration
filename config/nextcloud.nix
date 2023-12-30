{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.nextcloud;
in
{
  options = {
    mlt.nextcloud = with types; {
      enable = mkEnableOption "NextCloud";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.nextcloud_admin.sopsFile = ../secrets/services.yaml;
    services.nextcloud = {
      enable = true;
      config.adminpassFile = config.sops.secrets.nextcloud_admin.path;
      package = pkgs.nextcloud27;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit memories;
      };
      extraAppsEnable = true;
      hostname = "localhost";
    };
  };
}
