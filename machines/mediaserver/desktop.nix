# Configuration for server resources provided by this machine
{ config, pkgs, ... }:

{
  services.xserver = {
    videoDrivers = [ "amdgpu" ];
    enable = true;
    layout = "us";
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  # Allow non-free video drivers
  #nixpkgs.config.allowUnfree = true;
}
