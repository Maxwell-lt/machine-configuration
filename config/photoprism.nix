{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.photoprism;
in
{
  options = {
    mlt.photoprism = with types; {
      enable = mkEnableOption "PhotoPrism";
      storagePath = mkOption {
        description = "Path where photos will be stored";
        type = path;
        default = null;
      };
      importPath = mkOption {
        description = "Path where imports should be read";
        type = path;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.photoprism_admin.sopsFile = ../secrets/services.yaml;
    services.photoprism = {
      enable = true;
      passwordFile = config.sops.secrets.photoprism_admin.path;
      originalsPath = cfg.storagePath;
      importPath = toString cfg.importPath;
      address = "0.0.0.0";
      settings = {
        PHOTOPRISM_ORIGINALS_LIMIT = "-1";
        PHOTOPRISM_RESOLUTION_LIMIT = "-1";
        PHOTOPRISM_DISABLE_RESTART = "true";
        PHOTOPRISM_APP_NAME = "PhotoPrism (maxwell-lt.dev)";
      };
    };
    networking.firewall.allowedTCPPorts = [ 2342 ];

    # Workaround issue with PhotoPrism unable to write in its directories
    # https://github.com/NixOS/nixpkgs/issues/218061#issuecomment-1868001086
    systemd.services.photoprism.serviceConfig.DynamicUser = lib.mkForce false;
    users.users.photoprism = {
      group = "photoprism";
      isSystemUser = true;
    };
    users.groups.photoprism = { };
  };
}
