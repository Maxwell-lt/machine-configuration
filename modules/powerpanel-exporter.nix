{ config, lib, pkgs, options, ... }:

with lib;
{
  options = {
    services.powerpanel-exporter = with types; {
      enable = mkEnableOption "powerpanel-exporter";

      package = mkOption {
        description = "powerpanel-exporter package";
        defaultText = "pkgs.powerpanel-exporter";
        type = package;
        default = pkgs.callPackage ../powerpanel-exporter {};
      };

      port = mkOption {
        description = "Port to listen on";
        type = int;
        default = 9102;
      };
    };
  };

  config = let 
    cfg = config.services.powerpanel-exporter;
  in
  mkIf cfg.enable {
    systemd.services.prometheus-powerpanel-exporter = {
      enable = cfg.enable;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ (pkgs.callPackage ../powerpanel {}) ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/powerpanel-exporter \
          --port ${toString cfg.port} \
        '';
      };
    };

    environment.systemPackages = [
      (cfg.package)
    ];
  };
}
