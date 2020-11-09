{ stdenv, pkgs, fetchFromGitHub, ... }:

let mkRustPlatform = pkgs.callPackage ./mkRustPlatform.nix {};

    rustPlatform = mkRustPlatform {
      date = "2020-10-06";
      channel = "nightly";
    };

in rustPlatform.buildRustPackage rec {
  pname = "powerpanel-exporter";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "maxwell-lt";
    repo = pname;
    rev = version;
    sha256 = "0lcw5mny8bi9809zs74xjlm2zsa5amwkvfs80zjf68chkwa68jxw";
  };

  cargoSha256 = "03b6ibh1x5fwyxgh9lnn5bb9yg1scqyazazrvi08ckags29ygqhj";
  verifyCargoDeps = true;

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
}
