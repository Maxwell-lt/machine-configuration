{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ../../modules/neovim.nix
  ];

  home.packages = with pkgs; [
    #lutris
    playonlinux
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "library-of-babel" = {
        hostname = "maxwell-lt.dev";
        port = 22;
        user = "maxwell";
      };
      "media-server-alpha" = {
        hostname = "10.0.0.114";
        port = 22;
        user = "maxwell";
      };
      "maxwell-nixos" = {
        hostname = "10.0.0.156";
        port = 22;
        user = "maxwell";
      };
    };
  };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  nixpkgs.config.allowUnfree = true;

  home.file.".zshrc".source = ../../dotfiles/.zshrc;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "maxwell";
  home.homeDirectory = "/home/maxwell";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
