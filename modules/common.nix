{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal basics
    coreutils gitAndTools.gitFull wget vim man tree
    mkpasswd sshfs units progress pv ripgrep zip
    unzip p7zip gnupg unrar
    # System monitoring
    htop whois sysstat smartmontools pciutils
    dmidecode usbutils
    # File transfer
    wget sshfsFuse rsync
    # Media manipulation
    ffmpeg-full mkvtoolnix-cli imagemagickBig
  ];

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
      pinentryFlavor = "gnome3";
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
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ];
    hashedPassword = "$6$bJuwDnHiYHpdz$dSsXMl79Rx78pS.W.nQq7eLeoO1lA1OKiG.yq0Mo8vy4Vh66EjZDKvm1AC.aRU47zuvyiUwOx34wTHdM6hdiZ1";
    openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj9GfcWPMaytL62VZjvoYRpCT3wxyU6U+riB6gqy5UwozEDOY42NV/Mm2AFC5KQ9QjSC4UZB/Ws5+9q4OHCuRk7z7xCem3rUNDElqMtvmq9dfbaxEknzWucfLQZP8N7cQ/V62K01cSX0o1WwZqj2RZIjvnU5VDH49gOaep795MKOphW1aoXTUGQnhNw3mLDxnnnjjEEThLtac186pXaxDa/JgXBGvoJep2DBUiAXXaXohjMNQijVal/3txfzPOB1SPUnF5qy6qn/WvZfGiVPd3uI/ftLm9m+/O4xr0jeT1webfwyhyirnxFecS/W2pWGtxT6A8jKpiyOccTMDG847D maxwell@maxwell-gaming-mint"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD5LS315i42OMhMxkRjLrvdP65zDYdlD0hAOjXslf6JAhgvQu7CUbnLmMhivKlXp7z825NWrB66jlR5R6muO6bwoSDC9RID01ixcRv1iF4fmveDDXkSUy1MjeOdUOcml+zhh+IIi/SkGsjI7weqe0fKJCj1uIoru+UoIOjPeL0uC32Sl/GC9VRVGqiH57lIjkUaf9j3Ja9MvY63nx5W1+BIQuOlabEB2XD8hIUiEQEi0jNCCkAuvhnJjHIGSIRvUQBijInUGOR7M8eRmEwTrbl36DFIphnKKP+mhAefy5zIIMctdDucqyfweizLBg2D4qY1WiXHflng5k63h5WRYwvAyLJQ7Jy9/Dvm2eNYWhQ0bdGV0a3l3oRvthIReXgLuygWs9M/quCyb1VnNRYbxs1vRwI1MzN1EZ7W8OfX/5S3XNy3DBENoga4eA8xXanhSM3StRFpaYfx05E4x2tdQYQ2CMbps14oMEZ8bYc1cxD5r1aDfzzo2/0YkLGhVJVpoBrmCaQsHc07klqb+XwWTkqxdE/jTiNV3ZXXHlzD3Vt1jD8Goo2kMqjC1MGwFTUJAz20St3O/3ntka1sYZZJ8dDzU/ly6xI3xW1IN+o0A7Q9qpIIw4Lgc1eWEURH3/D2fnDTcFPIIh9h1oEEXldl0j6dWrw8f3XySBVBk7yNJzB0/Q== maxwell.lt@live.com"
        ];
  };
}