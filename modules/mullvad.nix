{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { };
in
{
  #imports = [ <nixos-unstable/nixos/modules/services/networking/mullvad-vpn.nix> ];

  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad-vpn
  ];

  # Workaround for NixOS/nixpkgs#91923
  networking.iproute2.enable = true;
}
