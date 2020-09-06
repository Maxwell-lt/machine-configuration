{ stdenv, pkgs, fetchFromGitHub, ... }:

let mkRustPlatform = pkgs.callPackage ./mkRustPlatform.nix {};

    rustPlatform = mkRustPlatform {
      date = "2020-08-29";
      channel = "nightly";
    };

in rustPlatform.buildRustPackage rec {
  pname = "zpool-exporter";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "1d3ylac1nxwbvnm63vipl064d2fj5lq7kcsgb1q83sb04kwm5lzd";
  };

  cargoSha256 ="1fg19psk9i9qk0wbbm081sh3g32csvyv3a4zrc9z2ybkq79znpkg";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
