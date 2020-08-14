{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix
      ../../modules/zfs.nix
      ../../modules/amdgpu.nix
      ../../modules/jellyfin.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "17ca4f0b";
    hostName = "media-server-alpha";
  };

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."media.maxwell-lt.dev" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8096";
      };
    };
    virtualHosts."68.43.125.230" = {
      locations."/" = {
        proxyPass = "https://localhost:8096";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "media.maxwell-lt.dev".email = "maxwell.lt@live.com";
    };
  };

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
