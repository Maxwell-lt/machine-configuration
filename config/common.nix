{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mlt.common;
in
{
  options = {
    mlt.common = with types; {
      enable = mkEnableOption "core programs and functionality";
      containers = mkEnableOption "container programs";
      media = mkEnableOption "media programs";
      user = {
        enable = mkEnableOption "user account";
        username = mkOption {
          description = "Username for primary user";
          type = str;
          default = "maxwell";
        };
        userDescription = mkOption {
          description = "Description of primary user account";
          type = str;
          default = "Maxwell L-T";
        };
        additionalExtraGroups = mkOption {
          description = "Additional groups to add the user to";
          type = listOf str;
          default = [];
        };
        additionalSSHKeys = mkOption {
          description = "Additional SSH keys to accept for remote logins";
          type = listOf str;
          default = [];
        };
        password = mkEnableOption "set password for account";
      };
      java = {
        enable = mkEnableOption "java";
        version = mkOption {
          description = "Java version to install";
          type = str;
          default = "21";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.containers {
      environment.systemPackages = with pkgs; [
        buildah         # Daemonless OCI container builder
        kubectl         # CLI for Kubernetes
        kubectx         # Switch between contexts
        kubernetes-helm # Deploy charts to K8s clusters
      ];
    })

    (mkIf cfg.media {
      environment.systemPackages = with pkgs; [
        abcde           # One-step CD ripping tool
        whipper         # Secure ripper, Linux equivalent of EAC
        flac            # FLAC CLI encoder, can also validate a .flac's internal checksum
        ffmpeg-full     # Fully featured media file manipulation tool
        imagemagickBig  # xkcd::2347
        mkvtoolnix-cli  # Matroska media container tools
        r128gain        # Add ReplayGain information to music files
        vorbisgain      # Add ReplayGain information to Vorbis-encoded music files. Used by abcde
        yt-dlp          # Download video/audio from YouTube
      ];
    })

    (mkIf cfg.user.enable {
      sops.secrets.password = mkIf cfg.user.password {
        sopsFile = ../secrets/password.yaml;
        neededForUsers = true;
      };
      users.users.${cfg.user.username} = {
        description = "${cfg.user.userDescription}";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = mkIf cfg.user.password config.sops.secrets.password.path;
        openssh.authorizedKeys.keys = cfg.user.additionalSSHKeys ++ [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE6RnS6RiN5u9vyXVKMZgnCsLJOuXaqADbDQWfShufCv maxwell@nix-portable-omega"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/qNB6f8IaU2BuI9AsHodHuOoaPabGNogUJQUs2etXE maxwell@pixel"
        ];
        # Set shell to zsh if core is enabled
        shell = mkIf cfg.enable pkgs.zsh;
      };
    })

    (mkIf cfg.enable {
      sops = {
        defaultSopsFile = ../secrets/general.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

      environment.systemPackages = with pkgs; [
        # Core utilities
        coreutils           # Basic GNU utilities
        findutils           # GNU find/xargs commands
        man                 # Documentation for everything
        mkpasswd            # Generate hashed passwords
        progress            # View current progress of coreutils tools
        pv                  # Monitor data moving through Unix pipes
        rename              # Bulk rename with Perl expressions
        tree                # View recursive directory listing
        units               # Unit conversions

        # Encryption
        easyrsa             # Scripts for generating x509 certs
        gnupg               # GNU Privacy Guard
        wireguard-tools     # Tools for Wireguard
        sops                # Tool for managing secrets
        ssh-to-age          # Convert SSH key to age key
        age                 # Modern encryption tool like PGP without the legacy junk

        # Archive handling
        p7zip               # 7zip archive tools
        unrar               # RAR file extraction
        unzip               # ZIP file extraction
        unar                # Extract from multiple archive types with one tool
        zip                 # ZIP file manipulation

        # JSON/YAML/etc.
        jq                  # JSON printing and manipulation
        jless               # JSON navigator
        yq                  # jq, but for YAML

        # Fancy terminal utilities
        bottom              # Fancy htop alternative
        eza                 # Fancy ls replacement
        fzf                 # Fuzzy finder
        parallel            # Much smarter xargs
        ripgrep             # Grep, but better

        # Nix tools
        nixpkgs-fmt           # Formatter for Nix files
        nix-prefetch-scripts  # Obtain hashes from multiple sources for use with Nix
        steam-run             # Quick and dirty method to run dynamic binaries in a FHS chroot with many included libraries

        # FS drivers
        dosfstools  # FAT/VFAT
        mtools      # More DOS fs compat
        ntfsprogs   # NTFS

        # System monitoring
        bmon          # Monitor network traffic
        dmidecode     # Read hardware information
        htop          # Interactive TUI process viewer
        lm_sensors    # Read hardware sensors
        nmap          # Network scanning and more
        pciutils      # Read and manipulate PCI devices
        smartmontools # View SMART information about drives
        sysstat       # Collection of performance monitoring tools
        usbutils      # USB tools, including lsusb
        whois         # WHOIS lookup
        dig           # DNS lookup

        # File transfer
        rsync       # Incremental file transfer
        sshfs-fuse  # Mount remote filesystem over SSH with FUSE
        wget        # Retrieve files from the web
      ];

      # Configure programs
      programs = {
        # Configuration system used by several applications
        dconf.enable = true;
        # Automatically load environments from a .envrc file
        direnv.enable = true;
        # Enable git
        git = {
          enable = true;
          lfs.enable = true;
        };
        # Enable GnuPG agent
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
        # Traces route to a pinged host and shows packet statistics
        mtr.enable = true;
        # Enable Neovim and set as the default editor
        neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };
        # Enable and configure ZSH
        zsh = {
          enable = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
          ohMyZsh = {
            enable = true;
            plugins = [ "git" "python" "nmap" "safe-paste" "spring" "gradle" "rust" "kubectl" ];
            theme = "agnoster";
            customPkgs = with pkgs; [
              pkgs.nix-zsh-completions
            ];
          };
          # Fix paste into zsh writing character-by-character
          shellInit = ''
            pasteinit() {
              OLD_SELF_INSERT=''${''${(s.:.)widgets[self-insert]}[2,3]}
              zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
            }

            pastefinish() {
              zle -N self-insert $OLD_SELF_INSERT
            }
            zstyle :bracketed-paste-magic paste-init pasteinit
            zstyle :bracketed-paste-magic paste-finish pastefinish
          '';
          shellAliases = {
            ls = "eza --icons";
            ll = "eza --icons -l --time-style long-iso";
            la = "eza --icons -l --time-style long-iso -a";
            lt = "eza --icons --tree -l";
          };
        };
      };

      # Update CPU microcode on both AMD and Intel chips
      hardware.cpu.intel.updateMicrocode = true;
      hardware.cpu.amd.updateMicrocode = true;

      # Configure Nix settings
      nix = {
        extraOptions = ''
          auto-optimise-store = true
          experimental-features = nix-command flakes
        '';
        gc.automatic = true;
        gc.dates = "Sat 05:00";
        gc.options = "--delete-older-than 14d";
        package = pkgs.nixFlakes;
      };

      # Disable password requirement for sudo command
      security.sudo.wheelNeedsPassword = false;

      # Enable fail2ban to block malicious SSH login attempts
      services.fail2ban.enable = true;

      # Enable SSH with password authentication disabled.
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      # Allow unfree packages to be installed.
      nixpkgs.config.allowUnfree = true;

      # Select locale and TTY font.
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };

      # Set time zone 
      time.timeZone = "America/New_York";

      # Manage user accounts declaratively
      users.mutableUsers = false;

      # Set root user's shell to zsh
      users.users.root = {
        shell = pkgs.zsh;
      };
    })
    (mkIf cfg.java.enable {
      programs.java = {
        enable = true;
        package = pkgs."jdk${cfg.java.version}";
      };
    })
  ];
}
