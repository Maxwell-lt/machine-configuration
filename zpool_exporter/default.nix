{ stdenv, pkgs, fetchFromGitHub, ... }:

let mkRustPlatform = pkgs.callPackage ./mkRustPlatform.nix {};

    rustPlatform = mkRustPlatform {
      date = "2020-08-29";
      channel = "nightly";
    };

in rustPlatform.buildRustPackage rec {
  pname = "zpool-exporter";
  version = "v0.1.1";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "157rzssfm5nsm931ixza7ww1cg0wjkrny30h53yya4ba585qvwgn";
  };

  cargoSha256 ="01mvgl51xz493kiih8p9ai45wg3q40xj912hj6q2z6y3m2qldkb0";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
