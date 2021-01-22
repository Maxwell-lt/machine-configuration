{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/zfs.nix
      ../../modules/common.nix
      ../../modules/desktop.nix
      ../../modules/nvidia.nix
      ../../services/zrepl.nix
    ];

  environment.systemPackages = with pkgs; [
    # Modify RGB configuration
    openrgb i2c-tools
    # Cheating the system
    flatpak

    (pkgs.callPackage ../../pkgs/svp {})
    (import ../../pkgs/svpflow/default.nix)
  ];

  # Disable HDMI audio output (gets set to the default on reboot/sleep/unlock)
  boot.blacklistedKernelModules = [
    "snd_hda_intel"
    "snd_hda_codec_hdmi"
  ];

  services.zrepl = {
    enable = true;
    push.rpool = {
      serverCN = "library-of-babel";
      sourceFS = "rpool/safe";
      targetHost = "158.69.224.168";
      targetPort = 8551;
      snapshotting.interval = 10;
    };
  };

  services.flatpak.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "79eefeea";
    hostName = "maxwell-nixos";
  };

  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlp41s0.useDHCP = true;

  # Needed for tc to work in the firewall script
  networking.firewall.extraPackages = with pkgs; [ iproute ];
  
  # Throttle zrepl traffic
  networking.firewall.extraCommands = ''
    # Clear previously-added tc rules
    # `|| true` is used to ignore errors from these lines, as they will fail if the tc rules are not already added 
    tc qdisc delete dev enp39s0 root handle 1:0 htb || true
    tc class delete dev enp39s0 parent 1:0 classid 1:1 htb rate 35Mbit ceil 35Mbit prio 1 || true
    # Add traffic control rules
    # This will limit traffic to 35Mbps, just under the max upload rate of the network
    tc qdisc add dev enp39s0 root handle 1:0 htb
    tc class add dev enp39s0 parent 1:0 classid 1:1 htb rate 35Mbit ceil 35Mbit prio 1
    # Add routing rule to redirect traffic from the zrepl user to the rate limited qdisc
    # The UID of the zrepl user is 316, as defined in the zrepl module
    ip46tables -t mangle -A POSTROUTING -o enp39s0 -p tcp -m owner --uid-owner 316 -j CLASSIFY --set-class 1:1
  '';

  # Needed to use erisia/builder
  nix.useSandbox = "relaxed";

  # Switch Pro Controller udev rules
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:057E:2009.*", MODE="0666"
  '';

  # Don't change this value from 20.03!
  system.stateVersion = "20.03"; # Did you read the comment?
}
