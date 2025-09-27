# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x5000cca22df6b3dd"; # or "nodev" for efi only

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      # These snapshots are for Minecraft, so we want a lot of recent snapshots and not a lot of old snapshots
      frequent = 16;
      hourly = 36;
      monthly = 6;
    };
    autoScrub = {
      enable = true;
      interval = "Sat 05:00";
    };
    trim = {
      enable = true;
      interval = "Sat 05:00";
    };
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
          name = "zrepl_sink";
          root_fs = "rpool/backup";
          serve = {
            ca = "/var/spool/zrepl/ca.crt";
            cert = "/var/spool/zrepl/library-of-babel.crt";
            key = "/var/spool/zrepl/library-of-babel.key";
            client_cns = [
              "media-server-alpha"
              "maxwell-nixos"
              "nix-portable-omega"
            ];
            listen = ":8550";
            type = "tls";
          };
          type = "sink";
        }
      ];
    };
    #sink."media-server-alpha-ssd" = {
    #  targetFS = "rpool/backup/media-server-alpha-ssd";
    #  clients = [
    #    "media-server-alpha"
    #    "maxwell-nixos"
    #    "nix-portable-omega"
    #  ];
    #  port = 8551;
    #  openFirewall = true;
    #};
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.eno2.useDHCP = true;
  networking = {
    hostId = "5bb88779";
    hostName = "library-of-babel";
  };

  # Setup Wireguard server
  networking = {
    nat = {
      enable = true;
      externalInterface = "eno1";
      internalInterfaces = [ "wg0" ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;

      # Act as a VPN (unneeded for now)
      #postSetup = ''
      #  ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE
      #'';

      #postShutdown = ''
      #  ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE
      #'';

      privateKeyFile = "/root/private";

      peers = [
        {
          publicKey = "1n83gP4hK7vLUpvh4m5tYMT/Nlij1AF9XeiTdMtgIE8=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          publicKey = "fpAVHIb6zeR1pavzcw5gvrsJhAQf/9rMSpBuI35A7Fw=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        {
          publicKey = "u02RNnEoI2W/kZiFAY1OG6i7KnpEMgq+VpSHnVt9Ck0=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
        {
          publicKey = "S+U8WhWiLl9NOzvFb1QGZg6brrGpnAVp0dfrQ5PsrCk=";
          allowedIPs = [ "10.100.0.5/32" ];
        }
        {
          publicKey = "3e412tg0Wb4tdNmiggInlgG8cI6P5GzJeC0u9PxXrUw=";
          allowedIPs = [ "10.100.0.6/32" ];
        }
        {
          publicKey = "gyBBNMjaWfONNt6C4aM78wuG+kMdOJFPSg9HAVt4b2U=";
          allowedIPs = [ "10.100.0.7/32" ];
        }
      ];
    };
  };

  nix = {
    extraOptions = "auto-optimise-store = true";
    gc.automatic = true;
    gc.dates = "Sat 05:00";
    gc.options = "--delete-older-than 14d";
  };

  security = {
    sudo.wheelNeedsPassword = false;
  };
  services.fail2ban.enable = true;

  # Allow unfree packages to be installed.
  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    # Terminal tools
    coreutils gitAndTools.gitFull wget vim man tree
    mkpasswd sshfs units progress pv ripgrep zip
    unzip p7zip gnupg unrar git-lfs direnv easyrsa
    wireguard-tools nix-output-monitor
    # FS drivers
    dosfstools mtools ntfsprogs
    # System monitoring
    htop whois sysstat smartmontools pciutils
    dmidecode usbutils nmap lm_sensors bmon
    # File transfer
    wget sshfs-fuse rsync
    # Media manipulation
    ffmpeg-full mkvtoolnix-cli imagemagickBig yt-dlp
    r128gain
    # Fonts
    powerline-fonts corefonts noto-fonts noto-fonts-cjk-sans
    noto-fonts-emoji noto-fonts-extra
  ];

  programs = {
    dconf.enable = true;
    tmux.enable = true;
    java.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nano.nanorc = ''
      set tabstospaces
      set tabsize 2
      set autoindent
      set smarthome
      set linenumbers
    '';
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "python" "nmap" "safe-paste" "spring" "gradle" "rust" ];
        theme = "agnoster";
        customPkgs = with pkgs; [
          nix-zsh-completions
        ];
      };
    };
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  users.mutableUsers = false;
  users.users.maxwell = {
    description = "Maxwell L-T";
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" ];
    hashedPassword = "$6$bJuwDnHiYHpdz$dSsXMl79Rx78pS.W.nQq7eLeoO1lA1OKiG.yq0Mo8vy4Vh66EjZDKvm1AC.aRU47zuvyiUwOx34wTHdM6hdiZ1";
    openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6RnS6RiN5u9vyXVKMZgnCsLJOuXaqADbDQWfShufCv maxwell@nix-portable-omega"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/qNB6f8IaU2BuI9AsHodHuOoaPabGNogUJQUs2etXE maxwell@pixel"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2M9+aenrZ9xCtrF1zsQTgmUeQjj5mzSgD6Y9lARWB+ JuiceSSH"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHd5DZKyDi6DicHeqDekEXAVQAtaiPMlacve0Mv3IdT maxwell@nix-portable-psi"
        ];
    shell = pkgs.zsh;
  };
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    443
    8550 # zrepl
    25565 # Minecraft
  ];
  networking.firewall.allowedUDPPorts = [ 
    51820   # Wireguard
  ];

  # Setup caddy
  services.caddy = {
    enable = true;
    email = "maxwell.lt@live.com";
    globalConfig = ''
      grace_period 1m
    '';
    extraConfig = ''
      (headers) {
        header X-Clacks-Overhead "GNU Terry Pratchett"
        header X-XSS-Protection "1; mode=block"
        header Referrer-Policy "no-referrer-when-downgrade"

        encode zstd gzip
        handle_errors {
          header content-type "text/plain"
          respond "{http.error.status_code} {http.error.status_text}"
        }
      }

      (auth) {
        forward_auth 10.100.0.2:9091 {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      }

      # Auth portal
      auth.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.2:9091
      }

      # Redirect home page to Firebase
      maxwell-lt.dev {
        redir https://www.maxwell-lt.dev{uri}
      }

      # Jellyfin media server
      media.maxwell-lt.dev {
        import headers
        import auth
        reverse_proxy 10.100.0.2:8096
      }

      # Home Assistant
      hass.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.3:8123
      }

      # Immich photo repository
      photos.maxwell-lt.dev {
        import headers
        request_body {
          max_size 10GB
        }
        reverse_proxy 10.100.0.2:2283
      }

      # Forgejo Git host
      git.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.2:3000
      }

      # Game demo
      game-demo.maxwell-lt.dev {
        import headers
        header Cache-Control max-age=1800
        root * /var/www/game
        file_server
      }

      # e34 Dynmap
      map.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:8123
      }

      # e34 website
      minecraft.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:9990
      }

      # ArgoCD
      argocd.kube.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.2:28080
      }

      # Coder
      coder.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:3000
      }

      # Grocy
      grocy.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:8900
      }
    '';
  };

  services.nginx = {
    enable = true;
    streamConfig = ''
      server {
        listen 25565;
        proxy_pass 10.100.0.5:25565;
      }
    '';
  };

  services.grafana = {
    enable = false;
    settings."auth.anonymous".enabled = true;
  };

  services.prometheus = {
    enable = false;
    globalConfig = {
      evaluation_interval = "20s";
      scrape_interval = "20s";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{
          targets = [ "localhost:9090" ];
        }];
      }
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" "10.100.0.2:9100" ];
        }];
      }
      {
        job_name = "zpool-exporter";
        static_configs = [{
          targets = [ "localhost:9101" "10.100.0.2:9101" ];
        }];
      }
      {
        job_name = "minecraft";
        static_configs = [{
          targets = [ "localhost:1223" ];
        }];
      }
      {
        job_name = "powerpanel-exporter";
        static_configs = [{
          targets = [ "10.100.0.2:9102" ];
        }];
      }
      {
        job_name = "zrepl";
        static_configs = [{
          targets = [ "localhost:9811" "10.100.0.2:9811" "10.100.0.2:9812" ];
        }];
      }
    ];
    exporters = {
      node.enable = true;
    };
  };
  services.zpool-exporter = {
    enable = false;
    datasets = [ "rpool" ];
    properties = [ "used" "available" ];
  };

  #nix.settings.sandbox = "relaxed";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

