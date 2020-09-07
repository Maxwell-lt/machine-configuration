{ stdenv, pkgs, fetchFromGitHub, ... }:

let mkRustPlatform = pkgs.callPackage ./mkRustPlatform.nix {};

    rustPlatform = mkRustPlatform {
      date = "2020-08-29";
      channel = "nightly";
    };

in rustPlatform.buildRustPackage rec {
  pname = "zpool-exporter";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "09j6a9sax7knxwi5g45kd6h5fhgldmznkypzinh45dgnzh70r781";
  };

  cargoSha256 ="1gp82f7kdxsf2kmbwfsyscbh0aqnpbq0lmkr657q7ip4x6c73kpy";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
