{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix
      ../../modules/zfs.nix
      ../../modules/amdgpu.nix
      ../../modules/jellyfin.nix
      ../../modules/zrepl.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "17ca4f0b";
    hostName = "media-server-alpha";
  };

  services.zrepl = {
    enable = true;
    push.ssdpool = {
      serverCN = "library-of-babel";
      sourceFS = "ssdpool";
      exclude = [
        "ssdpool/root/nixos"
        "ssdpool/reserved"
      ];
      targetHost = "158.69.224.168";
      targetPort = 8551;
      snapshotting.interval = 10;
    };
    push.rustpool = {
      serverCN = "library-of-babel";
      sourceFS = "rustpool/media";
      exclude = [ ];
      targetHost = "158.69.224.168";
      targetPort = 8551;
      snapshotting.interval = 10;
    };
  };

  # Needed for tc to work in the firewall script
  networking.firewall.extraPackages = with pkgs; [ iproute ];

  # Throttle zrepl traffic
  networking.firewall.extraCommands = ''
    # Clear previously-added tc rules
    # `|| true` is used to ignore errors from these lines, as they will fail if the tc rules are not already added
    tc qdisc delete dev enp0s31f6 root handle 1:0 htb || true
    tc class delete dev enp0s31f6 parent 1:0 classid 1:1 htb rate 35Mbit ceil 35Mbit prio 1 || true
    # Add traffic control rules
    # This will limit traffic to 35Mbps, just under the max upload rate of the network
    tc qdisc add dev enp0s31f6 root handle 1:0 htb
    tc class add dev enp0s31f6 parent 1:0 classid 1:1 htb rate 35Mbit ceil 35Mbit prio 1
    # Add routing rule to redirect traffic from the zrepl user to the rate limited qdisc
    # The UID of the zrepl user is 316, as defined in ../../modules/zrepl.nix
    ip46tables -t mangle -A POSTROUTING -o enp0s31f6 -p tcp -m owner --uid-owner 316 -j CLASSIFY --set-class 1:1
  '';

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
