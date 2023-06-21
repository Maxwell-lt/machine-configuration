{
  description = "Flakes for building systems";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
  };

  outputs = { self, nixpkgs, sops-nix }: {
    nixosConfigurations = 
    let
      buildSystem = config: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = config ++ [ sops-nix.nixosModules.sops ];
      };
    in
    {
      maxwell-nixos = buildSystem [
        ./machines/workstation/configuration.nix
      ];
      media-server-alpha = buildSystem [
        ./machines/mediaserver/configuration.nix
      ];
      nix-portable-omega = buildSystem [
        ./machines/laptop/configuration.nix
      ];
      library-of-babel = buildSystem [
        ./machines/library-of-babel/configuration.nix
      ];
    };
  };
}
