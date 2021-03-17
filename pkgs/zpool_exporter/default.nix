{ stdenv, pkgs, fetchFromGitHub, ... }:

let mkRustPlatform = pkgs.callPackage ./mkRustPlatform.nix {};

    rustPlatform = mkRustPlatform {
      date = "2020-08-29";
      channel = "nightly";
    };

in rustPlatform.buildRustPackage rec {
  pname = "zpool-exporter";
  version = "v0.2.1";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "0dl1b5wkgfvnxmp8hmrhc43j0k598x90l6rr2kw2y8jgxv5vrgr1";
  };

  cargoSha256 ="1xvmrm994qiai49c01mn2kbarxkssm5cqwjqzm998v3wx30fllrf";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
