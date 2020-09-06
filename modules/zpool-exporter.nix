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
        default = pkgs.callPackage ../zpool_exporter {};
      };

      port = mkOption {
        description = "Port to listen on";
        type = int;
        default = 9101;
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
          ${cfg.package}/bin/zpool_exporter
        '';
      };
    };

    environment.systemPackages = [
      (cfg.package)
    ];
  };
}
