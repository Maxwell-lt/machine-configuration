{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.docker;
in
{
  options = {
    mlt.docker = with types; {
      enable = mkEnableOption "docker";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    mlt.common.user.additionalExtraGroups = [ "docker" ];
  };
}
