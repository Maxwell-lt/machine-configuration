{ stdenv, pkgs, fetchFromGitHub, rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  pname = "zpool-exporter";
  version = "v0.3.0";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "sha256-iW8fu/Lj2UivNBnEIZ1/EikQBte3RIoXZEw1HHxoyMg=";
  };

  cargoSha256 ="sha256-WndbJkTFIdpkaB1AbJdLmpQE++lT+qs7/VmtH6Cq6pk=";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
