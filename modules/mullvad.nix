{ config, pkgs, fetchurl, lib, ... }:

{
  services.mullvad-vpn.enable = true;
  
  environment.systemPackages = with pkgs; [
    mullvad-vpn
  ];

  networking.wireguard.enable = true;

  # Until nixpkgs/pull/121906 is merged
  networking.firewall.checkReversePath = "loose";
}
