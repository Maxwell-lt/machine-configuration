{ config, pkgs, fetchurl, lib, ... }:

{
  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad-vpn
  ];

  # Workaround for NixOS/nixpkgs#91923
  networking.iproute2.enable = true;
}
