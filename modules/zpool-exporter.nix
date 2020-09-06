{ config, lib, pkgs }:

{
  options = {
    services.prometheus.exporters.zpool-exporter {
      enable = mkEnableOption "zpool-exporter";

      package = mkOption {
        description = "zpool-exporter package";
        defaultText = "pkgs.zpool-exporter";
        type = "package";
        default = pkgs.callPackage ../zpool_exporter {};
      }

      port = mkOption {
        description = "Port to listen on";
        type = int;
        default = 9101;
      }
    }
  }
  config = let 
    cfg = config.services.prometheus.exporters.zpool-exporter;
  in

  lib.mkIf cfg.enable {
    serviceOpts = {
      serviceConfig = {
        ExecStart = ''
          ${pkgs.zpool-exporter}/bin/zpool_exporter
        '';
      };
    };

    environment.systemPackages = [
      (cfg.package)
    ];
  }
}
