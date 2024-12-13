{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ../../secrets/services.yaml;

  mlt = {
    common = {
      enable = true;
      containers = true;
      media = true;
      user = {
        enable = true;
        password = true;
      };
    };
    jellyfin.enable = true;
    zfs.enable = true;
    lldap.enable = true;
    authelia.enable = true;
    forgejo.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/media/immich";
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.postgresql = {
    package = pkgs.postgresql;
  };

  services.invokeai = {
    enable = true;
    package = pkgs.invokeai-nvidia;
    settings.host = "0.0.0.0";
  };

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
            "rustpool/dynmap<" = false;
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
      listen = [
        {
          addr = "10.100.0.2";
          port = 9812;
        }
      ];
      locations."/" = {
        proxyPass = "http://10.0.0.156:9811";
      };
    };
  };

  # Needed for tc to work in the firewall script
  networking.firewall.extraPackages = with pkgs; [ iproute2 ];

  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    # Prometheus exporters
    9100
    9101
    9102
    9811
    9812
    # InvokeAI
    9090

    # K3s
    6443
    # K3s Traefik
    28080
    28443
  ];

  # Setup Wireguard client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];

    privateKeyFile = "/root/private";

    peers = [
      {
        publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";

        allowedIPs = [ "10.100.0.0/24" ];

        endpoint = "158.69.224.168:51820";

        persistentKeepalive = 25;
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.prometheus.exporters = {
    node.enable = true;
  };

  services.zpool-exporter = {
    enable = false;
    datasets = [
      "ssdpool"
      "rustpool"
    ];
  };

  services.powerpanel-exporter = {
    enable = false;
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

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      "--snapshotter=zfs"
      "--kube-apiserver-arg=oidc-issuer-url=https://auth.maxwell-lt.dev"
      "--kube-apiserver-arg=oidc-client-id=cbadd492-86d0-445e-93a7-587c6190a386"
      "--kube-apiserver-arg=oidc-username-claim=email"
      "--kube-apiserver-arg=oidc-groups-claim=groups"

    ];
  };

  systemd.services.k3s = {
    wants = [ "containerd.service" ];
    after = [ "containerd.service" ];
  };

  systemd.services.containerd.serviceConfig = {
    ExecStartPre = [
      "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs ssdpool/containerd"
    ];
  };

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs;[
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
  };

  nix.settings.sandbox = "relaxed";

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
