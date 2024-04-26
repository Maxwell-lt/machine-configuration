{ config, pkgs, lib, ... }:
let
  itgmania = pkgs.callPackage ../../pkgs/itgmania-bin {};
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  environment.systemPackages = [
    itgmania
    pkgs.comma
  ];

  services.cage = {
    enable = true;
    program = "${itgmania}/opt/itgmania/itgmania";
    user = "itg";
  };

  systemd.services."cage-tty1" = {
    after = [
      "network-online.target"
      "systemd-resolved.service"
    ];
    serviceConfig = {
      Restart = "on-failure";
    };
  };

  users.mutableUsers = false;
  users.allowNoPasswordLogin = true;
  users.users.itg = {
    isNormalUser = true;
    createHome = true;
    password = "password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXD8KKr1XyV3aOsb9eeagSrLY3A5L1nPgXnLO6XpSwc maxwell.lt@maxwell-nixos"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXD8KKr1XyV3aOsb9eeagSrLY3A5L1nPgXnLO6XpSwc maxwell.lt@maxwell-nixos"
  ];

  # Enable fail2ban to block malicious SSH login attempts
  services.fail2ban.enable = true;

  # Enable SSH with password authentication disabled.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  sops = {
    secrets."wireless.env" = {
      sopsFile = ../../secrets/wifi.yaml;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "249783fe";
    hostName = "itg";
  };

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.networkmanager.enable = false;
  networking.wireless = {
    environmentFile = config.sops.secrets."wireless.env".path;
    enable = true;
    networks = {
      "@home_uuid@" = {
        psk = "@home_psk@";
        priority = 40;
      };
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  system.stateVersion = "23.11";
}
