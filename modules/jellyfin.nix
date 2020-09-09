{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      8096 8920 # Web frontend
    ];
    allowedUDPPorts = [
      1900 7359 # Discovery
    ];
  };

  services.jellyfin =
  {
    enable = true;
    package = pkgs.jellyfin; # Upgrade to 10.6.x
  };
}
