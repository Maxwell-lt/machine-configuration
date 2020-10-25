{ config, pkgs, fetchurl, lib, ... }:

{
  services.mullvad-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    mullvad-vpn
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    mullvad-vpn = pkgs.mullvad-vpn.overrideAttrs (old: rec {
      version = "2020.6";
      src = pkgs.fetchurl {
        url = "https://www.mullvad.net/media/app/MullvadVPN-${version}_amd64.deb";
        sha256 = "0d9rv874avx86jppl1dky0nfq1633as0z8yz3h3f69nhmcbwhlr3";
      };
    });
  };

  # Workaround for NixOS/nixpkgs#91923
  networking.iproute2.enable = true;
}
