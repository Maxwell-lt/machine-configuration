{ callPackage, fetchFromGitHub, makeRustPlatform }:

{ date, channel }:

let mozillaOverlay = fetchFromGitHub {
          owner = "mozilla";
          repo = "nixpkgs-mozilla";
          rev = "7c1e8b1dd6ed0043fb4ee0b12b815256b0b9de6f";
          sha256 = "1a71nfw7d36vplf89fp65vgj3s66np1dc0hqnqgj5gbdnpm1bihl";
        };
    mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
    rustSpecific = (mozilla.rustChannelOf { inherit date channel; }).rust;

in makeRustPlatform {
  cargo = rustSpecific;
  rustc = rustSpecific;
}
