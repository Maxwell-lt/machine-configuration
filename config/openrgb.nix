{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.openrgb;
in
{
  options = {
    mlt.openrgb = with types; {
      enable = mkEnableOption "OpenRGB";
      motherboard = mkOption {
        description = "CPU family of motherboard";
        type = nullOr (enum [ "amd" "intel" ]);
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = mkIf (cfg.motherboard != null) cfg.motherboard;
    };
    environment.systemPackages = [ pkgs.i2c-tools ];
  };
}
