{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = "auto-optimise-store = true";
    gc = {
      automatic = true;
      dates = "Sat 05:00";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "library-of-akasha";
    hostId = "c7efddda";
    interfaces.enp1s0f0.useDHCP = true;
    nat = {
      enable = true;
      externalInterface = "enp1s0f0";
      internalInterfaces = [ "wg0" ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
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
    firewall = {
      allowedTCPPorts = [
        443
        8550 # zrepl
        25565 # Minecraft
      ];
      allowedUDPPorts = [
        51820 # wg
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  services.fail2ban.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.mutableUsers = false;
  users.users.maxwell = {
    description = "Maxwell L-T";
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" ];
    hashedPassword = "$6$bJuwDnHiYHpdz$dSsXMl79Rx78pS.W.nQq7eLeoO1lA1OKiG.yq0Mo8vy4Vh66EjZDKvm1AC.aRU47zuvyiUwOx34wTHdM6hdiZ1";
    openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXD8KKr1XyV3aOsb9eeagSrLY3A5L1nPgXnLO6XpSwc maxwell.lt@live.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHd5DZKyDi6DicHeqDekEXAVQAtaiPMlacve0Mv3IdT maxwell@nix-portable-psi"
        ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    # Terminal tools
    coreutils gitFull wget vim man tree
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
    noto-fonts-color-emoji
  ];

  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      frequent = 8;
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
    enable = false;
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
          root_fs = "rustpool/backup";
          serve = {
            ca = "/var/spool/zrepl/ca.crt";
            cert = "/var/spool/zrepl/library-of-akasha.crt";
            key = "/var/spool/zrepl/library-of-akasha.key";
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
  };

  programs = {
    dconf.enable = true;
    tmux.enable = true;
    java.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
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

  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

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
      #auth.maxwell-lt.dev {
      #  import headers
      #  reverse_proxy 10.100.0.2:9091
      #}

      # Redirect home page to Firebase
      #maxwell-lt.dev {
      #  redir https://www.maxwell-lt.dev{uri}
      #}

      # Jellyfin media server
      #media.maxwell-lt.dev {
      #  import headers
      #  import auth
      #  reverse_proxy 10.100.0.2:8096
      #}

      # Immich photo repository
      #photos.maxwell-lt.dev {
      #  import headers
      #  request_body {
      #    max_size 10GB
      #  }
      #  reverse_proxy 10.100.0.2:2283
      #}

      # Forgejo Git host
      #git.maxwell-lt.dev {
      #  import headers
      #  reverse_proxy 10.100.0.2:3000
      #}
      
      # e34 website
      minecraft.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:9990
      }

      # ArgoCD
      #argocd.kube.maxwell-lt.dev {
      #  import headers
      #  reverse_proxy 10.100.0.2:28080
      #}

      # Grocy
      grocy.maxwell-lt.dev {
        import headers
        reverse_proxy 10.100.0.5:8900
      }
    '';
  };


  # Proxy Minecraft traffic
  services.nginx = {
    enable = true;
    streamConfig = ''
      server {
        listen 25565;
        proxy_pass 10.100.0.5:25565;
      }
    '';
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?

}

