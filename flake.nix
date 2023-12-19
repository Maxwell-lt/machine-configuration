{
  description = "Flakes for building systems";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
    nixified-ai = {
      url = "github:nixified-ai/flake";
    };
  };

  outputs = inputs@{ self, nixpkgs, sops-nix, nixified-ai }: {
    nixosConfigurations = 
    let
      buildSystem = config: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = config ++ [ sops-nix.nixosModules.sops ];
        specialArgs = { inherit nixified-ai; };
      };
    in
    {
      maxwell-nixos = buildSystem [
        ./machines/workstation/configuration.nix
      ];
      media-server-alpha = buildSystem [
        ./machines/mediaserver/configuration.nix
        nixified-ai.nixosModules.invokeai
        { 
          environment.systemPackages = [ nixified-ai.packages.x86_64-linux.textgen-nvidia ];
          nixpkgs.overlays = [
            (final: prev: {
              invokeai-nvidia = nixified-ai.packages.x86_64-linux.invokeai-nvidia;
            })
          ];
          nix.settings = {
            trusted-substituters = ["https://ai.cachix.org"];
            trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];
          };
        }
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
