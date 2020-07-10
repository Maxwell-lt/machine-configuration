{ config, pkgs, ... }:

{
    services.xserver.videoDrivers = [ "nvidia" ];
}