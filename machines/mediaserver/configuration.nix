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
      #../../modules/grocy.nix
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
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 6x14d";
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
            "ssdpool/root/nixos<" = false;
            "ssdpool/root/nixos" = true;
            "ssdpool/containerd<" = false;
          };
          name = "ssdpool_push";
          pruning = {
            keep_receiver = [
              {
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 6x14d";
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
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."zrepl_forwarder" = {
      serverName = "10.100.0.2";
      listen = [{
        addr = "10.100.0.2";
        port = 9812;
      }];
      locations."/" = {
        proxyPass = "http://10.0.0.156:9811";
      };
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
    # The UID of the zrepl user is 316, as defined in the zrepl module
    ip46tables -t mangle -A POSTROUTING -o enp0s31f6 -p tcp -m owner --uid-owner 316 -j CLASSIFY --set-class 1:1
  '';

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    # Prometheus exporters
    9100 9101 9102 9811 9812
    # K3s
    6443
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      "--snapshotter=zfs"
    ];
  };

  systemd.services.k3s = {
    wants = ["containerd.service"];
    after = ["containerd.service"];
  };

  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri".cni = {
        bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
          mkdir -p $out
          ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
        ''}";
        conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
      };
    };
  };

  systemd.services.containerd.serviceConfig = {
    ExecStartPre = [
      "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs ssdpool/containerd"
    ];
  };

  # Expose paths on NFS for K3s to access
  fileSystems = {
    "/export/qbconf" = {
      device = "/mnt/media/config/qbittorrent";
      options = [ "bind" ];
    };
    "/export/torrents" = {
      device = "/mnt/media/staging/torrents";
      options = [ "bind" ];
    };
    "/export/tv" = {
      device = "/mnt/media/tv";
      options = [ "bind" ];
    };
    "/export/movies" = {
      device = "/mnt/media/movies";
      options = [ "bind" ];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export           10.0.0.114(rw,fsid=0,no_subtree_check)
      /export/qbconf    10.0.0.114(rw,nohide,insecure,no_subtree_check,no_root_squash)
      /export/torrents  10.0.0.114(rw,nohide,insecure,no_subtree_check,no_root_squash)
      /export/tv        10.0.0.114(rw,nohide,insecure,no_subtree_check,no_root_squash)
      /export/movies    10.0.0.114(rw,nohide,insecure,no_subtree_check,no_root_squash)
    '';
  };

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
