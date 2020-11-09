{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ../../modules/neovim.nix
  ];

  home.packages = with pkgs; [
    getconf
    ripgrep
    openssh
  ];

  programs.direnv.enable = true;
  services.lorri.enable = true;

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    history.extended = true;
    localVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
      EDITOR = "nvim";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "nmap" "safe-paste" ];
      theme = "agnoster";
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "library-of-babel" = {
        hostname = "maxwell-lt.dev";
        port = 22;
        user = "maxwell";
      };
      "media-server-alpha" = {
        hostname = "10.100.0.2";
        port = 22;
        user = "maxwell";
        proxyJump = "library-of-babel";
      };
      "maxwell-nixos" = {
        hostname = "10.0.0.156";
        port = 22;
        user = "maxwell";
        proxyJump = "media-server-alpha";
      };
    };
  };

  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
