{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.osu-lazer ];

  nixpkgs.overlays = [
    (final: prev: {
      osu-lazer = prev.osu-lazer.overrideAttrs (old: rec {
        version = "2023.1218.0";
        src = final.fetchFromGitHub {
          owner = "ppy";
          repo = "osu";
          rev = version;
          sha256 = "sha256-CwvWA15ytPE/JION9Xc+bbG8GRDHubfWQauovm2tNAE=";
        };
      });
    })
  ];
}
