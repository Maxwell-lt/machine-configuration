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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = inputs@{ self, nixpkgs, sops-nix, nixified-ai, home-manager, hyprland, hyprland-plugins, ... }: {
    nixosConfigurations =
      let
        linux64System = "x86_64-linux";
        buildSystem = config: nixpkgs.lib.nixosSystem {
          system = linux64System;
          modules = config ++ [ 
            sops-nix.nixosModules.sops
            ./config
            {
                nix.settings = {
                  substituters = ["https://hyprland.cachix.org"];
                  trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
                };
            }
          ];
          specialArgs = { inherit inputs; };
        };
      in
      {
        maxwell-nixos = buildSystem [
          ./machines/workstation/configuration.nix
        ];
        media-server-alpha = (buildSystem [
          ./machines/mediaserver/configuration.nix
          nixified-ai.nixosModules.invokeai
          {
            environment.systemPackages = [ nixified-ai.packages.x86_64-linux.textgen-nvidia nixified-ai.packages.x86_64-linux.invokeai-nvidia ];
            nixpkgs.overlays = [
              (final: prev: {
                invokeai-nvidia = nixified-ai.packages.x86_64-linux.invokeai-nvidia;
              })
            ];
            nix.settings = {
              trusted-substituters = [ "https://ai.cachix.org" ];
              trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];
            };
          }
        ]) // { specialArgs = { inherit nixified-ai; }; };
        nix-portable-omega = buildSystem [
          ./machines/laptop/configuration.nix
        ];
        library-of-babel = buildSystem [
          ./machines/library-of-babel/configuration.nix
        ];
        rpi4-nixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./machines/r4spberrypi/configuration.nix ];
        };
      };
    homeConfigurations =
      let
        linux64System = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${linux64System};
        buildHome = config: home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = config;
          extraSpecialArgs = { inherit inputs; };
        };
      in
      {
        "maxwell@maxwell-nixos" = buildHome [
          machines/workstation/home.nix
          hyprland.homeManagerModules.default
        ];
        "maxwell@media-server-alpha" = buildHome [
          machines/mediaserver/home.nix
        ];
	"maxwell@nix-portable-omega" = buildHome [
	  machines/laptop/home.nix
	];
      };
  };
}
