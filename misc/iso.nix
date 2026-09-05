# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.
{ config, pkgs, ... }:
{
  mlt.common = {
    enable = true;
    user = {
      enable = true;
      password = false;
    };
  };

  networking = {
    hostName = "iso";
  };
}
