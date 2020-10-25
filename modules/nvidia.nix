{ config, pkgs, lib, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    nvtop
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    ffmpeg-full = pkgs.ffmpeg-full.override {
      nonfreeLicensing = true;
      nvenc = true;
    };
    obs-studio = pkgs.obs-studio.overrideAttrs (old: rec {
      buildInputs = (lib.remove pkgs.ffmpeg-full old.buildInputs) ++ [ ffmpeg-full ];
    });
  };
}
