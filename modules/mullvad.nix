{ config, pkgs, fetchurl, lib, ... }:

{
  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad-vpn
  ];

  # Workaround for NixOS/nixpkgs#91923
  networking.iproute2.enable = true;

  networking.wireguard.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    mullvad-vpn = pkgs.mullvad-vpn.overrideAttrs (old: rec {
      version = "2020.7";
      src = pkgs.fetchurl {
        url = "https://www.mullvad.net/media/app/MullvadVPN-${version}_amd64.deb";
        sha256 = "07vryz1nq8r4m5y9ry0d0v62ykz1cnnsv628x34yvwiyazbav4ri";
      };
    });
  };
}
