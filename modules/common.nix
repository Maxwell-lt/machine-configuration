{ config, pkgs, ... }:
let
  master = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/master)
    { config = config.nixpkgs.config; };
in

{
  environment.systemPackages = with pkgs; [
    # Terminal tools
    coreutils gitAndTools.gitFull wget vim man tree
    mkpasswd sshfs units progress pv ripgrep zip
    unzip p7zip gnupg unrar git-lfs direnv easyrsa
    findutils nix-prefetch-git wireguard
    # FS drivers
    dosfstools mtools ntfsprogs
    # System monitoring
    htop whois sysstat smartmontools pciutils
    dmidecode usbutils nmap lm_sensors bmon
    # File transfer
    wget sshfsFuse rsync
    # Media manipulation
    ffmpeg-full mkvtoolnix-cli imagemagickBig master.youtube-dl
    r128gain
  ];

  fonts.fonts = with pkgs; [
    powerline-fonts corefonts
    noto-fonts noto-fonts-cjk
    noto-fonts-emoji noto-fonts-extra
    hack-font ipafont
    
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Hack"
      "Noto Sans Mono CJK JP"
    ];

    sansSerif = [
      "Noto Sans"
      "Noto Sans CJK JP"
    ];

    serif = [
      "Noto Serif"
      "Noto Serif CJK JP"
    ];
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  nix = {
    extraOptions = "auto-optimise-store = true";
    gc.automatic = true;
    gc.dates = "Sat 05:00";
    gc.options = "--delete-older-than 14d";
  };

  security = {
    sudo.wheelNeedsPassword = false;
    #apparmor.enable = true;
  };
  services.fail2ban.enable = true;

  # Allow unfree packages to be installed.
  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set time zone to EST/EDT.
  time.timeZone = "America/New_York";

  programs = {
    dconf.enable = true;
    tmux.enable = true;
    java.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "qt";
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
        plugins = [ "git" "python" "nmap" "safe-paste" "spring" "gradle" "cargo" ];
        theme = "agnoster";
        customPkgs = with pkgs; [
          pkgs.nix-zsh-completions
        ];
      };
    };
  };

  # Enable SSH with password authentication disabled.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    passwordAuthentication = false;
  };

  services.lorri.enable = true;

  # Add one immutable user.
  users.mutableUsers = false;
  users.users.maxwell = {
    description = "Maxwell L-T";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" "jellyfin" ];
    hashedPassword = "$6$bJuwDnHiYHpdz$dSsXMl79Rx78pS.W.nQq7eLeoO1lA1OKiG.yq0Mo8vy4Vh66EjZDKvm1AC.aRU47zuvyiUwOx34wTHdM6hdiZ1";
    openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj9GfcWPMaytL62VZjvoYRpCT3wxyU6U+riB6gqy5UwozEDOY42NV/Mm2AFC5KQ9QjSC4UZB/Ws5+9q4OHCuRk7z7xCem3rUNDElqMtvmq9dfbaxEknzWucfLQZP8N7cQ/V62K01cSX0o1WwZqj2RZIjvnU5VDH49gOaep795MKOphW1aoXTUGQnhNw3mLDxnnnjjEEThLtac186pXaxDa/JgXBGvoJep2DBUiAXXaXohjMNQijVal/3txfzPOB1SPUnF5qy6qn/WvZfGiVPd3uI/ftLm9m+/O4xr0jeT1webfwyhyirnxFecS/W2pWGtxT6A8jKpiyOccTMDG847D maxwell@maxwell-gaming-mint"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQ7f4ZNV3mTgQt+6voyu6Xok7j/65Pb30+DndyNMNtlMwFVVPQbtlg28YrkXWQ2bE9hNsajIZnOgYsEgTFQUT0aFK0pR/hSBmYERfzK9vex0rewuJ0zDYR5ugAD+7CmxtPyUvij4bWRC7V32s1RSKgtA34mSu32pDzlXWwW36jiNs1sl8WEX9tR75X2VJ58Ng8QuVUPfXIaNW96UjyBKgvP2n8WQyWlaB6H4eJTlTR2ybgeCBMA9un7Y+oc9aSAQtDvJpb2ngu6hZ8bUKfFrz3gnXamKRQrRIwEYomKvus5SRkDnEOGXZY7f0q/dEEMgkTWy5skC8Vb1rda1uzD2L6hOCdW8FVOqnK1awjIr1hhas1F6Rr+fnEd30ozvFrmmz7DTh4+9JRgvbuo4vZRbH12vVy4OmZClhOHl04EsBJI6HdxLgcN7tx5QKS58WB6A2g8oihbIfK9SGqMhde2KcxKuD/EDIDWGFr10Q+cF2C4xH6qoBO5Um09boWbxDxcgV0yKcrRjntCf7iSKk3dTtMmtZUF02iPzq1f2UVnmR1c3CCKOU2XsalcFPUORthbN2DaKR3jS4J/dE/RaZg+DJqsTsXPOZL0MFSYu8FVvR0Vp4pJzMb9RDu9V7oYho+1UWORIN3cjx+di5CJO5/yQv7sM2ufBT2ggQ3bcjyR5Iacw== JuiceSSH"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLiENW3t+GR07SPLqU05udjHRQ6KZPFk4VMRBaLPxK9Q4jL8TgJjAEJoWo1tGQUfg8XefUS1VJkoENnLXdoLFkF0W5yHBYqy3UdQpEiuCtW7zs7MxOcAdqfhkr8n8YIz7ud2VyxUXoeVaAQDrXjUYcXIDPJEkXSTQLd6+1vgBuUfPoAQpbgDQGodBcxFPxMz4wXFcV2gvvRtVukUsQ56ux2kQzXyyqMXLO2BAJgiSMojCOSPdCq9ZhUr0gD1/Lf+DW6JAGo2BNNqjyw1ocHTU0cwhxpB9ZyPS78vAVhkzKcsUbnlJLSdLNd/0ybNBuZJKNUzQsNcOsID74mIAn3AfidFBNRKZLuBm2dCMtss22jTUC+MXKvM/2PS9xY97fOjic3yHEZBIx8u6VNen7sCubaC/impgetOJTRsQOlyoMD3uMrGoQeqn+jqi3+/c31+x5qELmo/VsYQxPuF9M5KoiBqhPDrh28H+vcpkw7bTqNOSaZA7ZGSIT1JqfAH6CtJo+hoRsH65WQCS3vIPrvpN6Y7vW6sSS8eYs22YvCGnow8KJ12dJGDa3rMsn3ZJj02xnfUbPuLnJMcx1B5fWDBXPlCPBGDxVaTw9mhIUtvokWBPUVzQg6t+x32i7ZbOEQR4s7DeWSK7aM2peLsaQXs44tlES79W9qG5UDrEM6JviIQ== maxwell@nix-portable-omega"
        ];
    shell = pkgs.zsh;
  };
}
