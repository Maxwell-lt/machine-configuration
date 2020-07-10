{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { };
in
{
  imports = [ <nixos-unstable/nixos/modules/services/networking/mullvad-vpn.nix> ];

  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.mullvad-vpn
  ];
}
