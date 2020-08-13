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
  boot.loader.grub.version = 2;
  boot.supportedFilesystems = [ "zfs" ];
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
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
    unzip p7zip gnupg unrar git-lfs direnv
    # FS drivers
    dosfstools mtools ntfsprogs
    # System monitoring
    htop whois sysstat smartmontools pciutils
    dmidecode usbutils nmap lm_sensors
    # File transfer
    wget sshfsFuse rsync
    # Media manipulation
    ffmpeg-full mkvtoolnix-cli imagemagickBig youtube-dl
    r128gain
    # Fonts
    powerline-fonts corefonts noto-fonts noto-fonts-cjk
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
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    passwordAuthentication = false;
  };

  users.mutableUsers = false;
  users.users.maxwell = {
    description = "Maxwell L-T";
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" ];
    hashedPassword = "$6$bJuwDnHiYHpdz$dSsXMl79Rx78pS.W.nQq7eLeoO1lA1OKiG.yq0Mo8vy4Vh66EjZDKvm1AC.aRU47zuvyiUwOx34wTHdM6hdiZ1";
    openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLiENW3t+GR07SPLqU05udjHRQ6KZPFk4VMRBaLPxK9Q4jL8TgJjAEJoWo1tGQUfg8XefUS1VJkoENnLXdoLFkF0W5yHBYqy3UdQpEiuCtW7zs7MxOcAdqfhkr8n8YIz7ud2VyxUXoeVaAQDrXjUYcXIDPJEkXSTQLd6+1vgBuUfPoAQpbgDQGodBcxFPxMz4wXFcV2gvvRtVukUsQ56ux2kQzXyyqMXLO2BAJgiSMojCOSPdCq9ZhUr0gD1/Lf+DW6JAGo2BNNqjyw1ocHTU0cwhxpB9ZyPS78vAVhkzKcsUbnlJLSdLNd/0ybNBuZJKNUzQsNcOsID74mIAn3AfidFBNRKZLuBm2dCMtss22jTUC+MXKvM/2PS9xY97fOjic3yHEZBIx8u6VNen7sCubaC/impgetOJTRsQOlyoMD3uMrGoQeqn+jqi3+/c31+x5qELmo/VsYQxPuF9M5KoiBqhPDrh28H+vcpkw7bTqNOSaZA7ZGSIT1JqfAH6CtJo+hoRsH65WQCS3vIPrvpN6Y7vW6sSS8eYs22YvCGnow8KJ12dJGDa3rMsn3ZJj02xnfUbPuLnJMcx1B5fWDBXPlCPBGDxVaTw9mhIUtvokWBPUVzQg6t+x32i7ZbOEQR4s7DeWSK7aM2peLsaQXs44tlES79W9qG5UDrEM6JviIQ== maxwell@nix-portable-omega"
        ];
    shell = pkgs.zsh;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

