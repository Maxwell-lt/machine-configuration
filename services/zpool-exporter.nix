{ config, lib, pkgs, options, ... }:

with lib;
{
  options = {
    services.zpool-exporter = with types; {
      enable = mkEnableOption "zpool-exporter";

      package = mkOption {
        description = "zpool-exporter package";
        defaultText = "pkgs.zpool-exporter";
        type = package;
        default = pkgs.callPackage ../pkgs/zpool_exporter {};
      };

      port = mkOption {
        description = "Port to listen on";
        type = int;
        default = 9101;
      };

      datasets = mkOption {
        description = "Datasets to get properties from";
        type = listOf string;
      };

      properties = mkOption {
        description = "Properties to retrieve from zfs get";
        type = listOf string;
        default = [ "used" "available" ];
      };
    };
  };

  config = let 
    cfg = config.services.zpool-exporter;
  in
  mkIf cfg.enable {
    systemd.services.prometheus-zpool-exporter = {
      enable = cfg.enable;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.zfs ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/zpool_exporter \
          --port ${toString cfg.port} \
          --datasets=${(concatStringsSep "," cfg.datasets)} \
          --properties=${(concatStringsSep "," cfg.properties)}
        '';
      };
    };

    environment.systemPackages = [
      (cfg.package)
    ];
  };
}
