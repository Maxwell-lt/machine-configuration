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

  users.users.immich.extraGroups = [ "video" "render" ];

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
      listen = [{
        addr = "10.100.0.2";
        port = 9812;
      }];
      locations."/" = {
        proxyPass = "http://10.0.0.156:9811";
      };
    };
    virtualHosts."serverpack" = {
      serverName = "10.100.0.2";
      listen = [{
        addr = "10.100.0.2";
        port = 9990;
      }];
      locations."/" = {
        root = "/srv/minecraft";
      };
      extraConfig = ''
        autoindex on;
      '';
    };
  };

  fileSystems."/srv/minecraft" = {
    device = "/home/minecraft/web";
    depends = ["/home/minecraft/web"];
    options = ["bind"];
  };

  # Needed for tc to work in the firewall script
  networking.firewall.extraPackages = with pkgs; [ iproute2 ];

  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [
    # Prometheus exporters
    9100 9101 9102 9811 9812
    # InvokeAI
    9090

    # Dynmap
    8123
    # Minecraft
    25565
    # Minecraft web site
    9990
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
    datasets = [ "ssdpool" "rustpool" ];
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

  users.users.minecraft = {
    description  = "Minecraft user account";
    isNormalUser = true;
    shell = pkgs.zsh;
    createHome = true;
    linger = true;
    packages = with pkgs; [
      tmux
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6RnS6RiN5u9vyXVKMZgnCsLJOuXaqADbDQWfShufCv maxwell@nix-portable-omega"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/qNB6f8IaU2BuI9AsHodHuOoaPabGNogUJQUs2etXE maxwell@pixel"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2M9+aenrZ9xCtrF1zsQTgmUeQjj5mzSgD6Y9lARWB+ JuiceSSH"
    ];
  };

  nix.settings.sandbox = "relaxed";

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
