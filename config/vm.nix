{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.vm;
in
{
  options = {
    mlt.vm = with types; {
      enable = mkEnableOption "VM tools";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    mlt.common.user.additionalExtraGroups = [ "libvirtd" ];
  };
}
