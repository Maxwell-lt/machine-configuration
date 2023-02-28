{ stdenv, pkgs, fetchFromGitHub, rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  pname = "powerpanel-exporter";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "sha256-Rsl/tnv3oBg3NTnP5vL9+/K4zQ5cdpUnSPiqNAZvPxI=";
  };

  cargoSha256 = "sha256-WZ/4m99KtsqmvzEEgYf5h7Nf2zsGBXQC6oYAKu+LDK4=";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
