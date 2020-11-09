{ callPackage, fetchFromGitHub, makeRustPlatform }:

{ date, channel }:

let mozillaOverlay = fetchFromGitHub {
      owner = "mozilla";
      repo = "nixpkgs-mozilla";
      rev = "efda5b357451dbb0431f983cca679ae3cd9b9829";
      sha256 = "11wqrg86g3qva67vnk81ynvqyfj0zxk83cbrf0p9hsvxiwxs8469";
    };
    mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
    rustSpecific = (mozilla.rustChannelOf { inherit date channel; }).rust;

in makeRustPlatform {
  cargo = rustSpecific;
  rustc = rustSpecific;
}
