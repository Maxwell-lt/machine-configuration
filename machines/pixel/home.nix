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
    inetutils
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
        hostname = "ssh.maxwell-lt.dev";
        port = 22;
        user = "maxwell";
      };
      "ext-media-server-alpha" = {
        hostname = "10.100.0.2";
        port = 22;
        user = "maxwell";
        proxyJump = "library-of-babel";
      };
      "ext-maxwell-nixos" = {
        hostname = "10.0.0.156";
        port = 22;
        user = "maxwell";
        proxyJump = "ext-media-server-alpha";
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
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
    enableDefaultConfig = false;
  };

  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
