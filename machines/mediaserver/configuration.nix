{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix
      ../../modules/zfs.nix
      ../../modules/amdgpu.nix
      ../../modules/jellyfin.nix
      #../../services/zrepl.nix
      ../../services/zpool-exporter.nix
      ../../services/powerpanel.nix
      ../../services/powerpanel-exporter.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "17ca4f0b";
    hostName = "media-server-alpha";
  };

  services.zrepl = {
    enable = true;
    settings = {
      global = {
        monitoring = [
          {
            listen = ":9811";
            type = "prometheus";
          }
        ];
      };
      jobs = [
        {
          connect = {
            address = "158.69.224.168:8550";
            ca = "/var/spool/zrepl/ca.crt";
            cert = "/var/spool/zrepl/media-server-alpha.crt";
            key = "/var/spool/zrepl/media-server-alpha.key";
            server_cn = "library-of-babel";
            type = "tls";
          };
          filesystems = {
            "rustpool/media<" = true;
          };
          name = "rustpool_push";
          pruning = {
            keep_receiver = [
              {
                grid = "24x1h | 30x1d | 6x14d";
                regex = "^zrepl_";
                type = "grid";
              }
            ];
            keep_sender = [
              {
                type = "not_replicated";
              }
              {
                grid = "1x3h(keep=all) | 24x1h | 7x1d";
                regex = "^zrepl_";
                type = "grid";
              }
            ];
          };
          snapshotting = {
            interval = "10m";
            prefix = "zrepl_";
            type = "periodic";
          };
          type = "push";
        }
        {
          connect = {
            address = "158.69.224.168:8550";
            ca = "/var/spool/zrepl/ca.crt";
            cert = "/var/spool/zrepl/media-server-alpha.crt";
            key = "/var/spool/zrepl/media-server-alpha.key";
            server_cn = "library-of-babel";
            type = "tls";
          };
          filesystems = {
            "ssdpool/reserved" = false;
            "ssdpool<" = true;
          };
          name = "ssdpool_push";
          pruning = {
            keep_receiver = [
              {
                grid = "24x1h | 30x1d | 6x14d";
                regex = "^zrepl_";
                type = "grid";
              }
            ];
            keep_sender = [
              {
                type = "not_replicated";
              }
              {
                grid = "1x3h(keep=all) | 24x1h | 7x1d";
                regex = "^zrepl_";
                type = "grid";
              }
            ];
          };
          snapshotting = {
            interval = "10m";
            prefix = "zrepl_";
            type = "periodic";
          };
          type = "push";
        }
      ];
    };
    #push.ssdpool = {
    #  serverCN = "library-of-babel";
    #  sourceFS = "ssdpool";
    #  exclude = [
    #    "ssdpool/reserved"
    #  ];
    #  targetHost = "158.69.224.168";
    #  targetPort = 8551;
    #  snapshotting.interval = 10;
    #};
    #push.rustpool = {
    #  serverCN = "library-of-babel";
    #  sourceFS = "rustpool/media";
    #  exclude = [ ];
    #  targetHost = "158.69.224.168";
    #  targetPort = 8551;
    #  snapshotting.interval = 10;
    #};
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
    # The UID of the zrepl user is 316, as defined in the zrepl module
    ip46tables -t mangle -A POSTROUTING -o enp0s31f6 -p tcp -m owner --uid-owner 316 -j CLASSIFY --set-class 1:1
  '';

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    # Prometheus exporters
    9100 9101 9102 9811
  ];

  # Setup Wireguard client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];

    privateKeyFile = "/root/private";

    peers = [
      {
        publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";

        allowedIPs = [ "10.100.0.1" ];

        endpoint = "158.69.224.168:51820";

        persistentKeepalive = 25;
      }
    ];
  };

  services.prometheus.exporters = {
    node.enable = true;
  };

  services.zpool-exporter = {
    enable = true;
    datasets = [ "ssdpool" "rustpool" ];
  };

  services.powerpanel-exporter = {
    enable = true;
  };

  services.powerpanel = {
    enable = true;
    powerfail = {
      scriptEnable = false;
      autoShutdown = false;
    };
    lowbatt = {
      scriptEnable = false;
      autoShutdown = false;
      lowbattThreshold = 20;
      runtimeThreshold = 300;
    };
    enableAlarm = true;
    turnUPSOff = false;
    hibernate = false;
  };

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
