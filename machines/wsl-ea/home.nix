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
    gitAndTools.gitFull
    wget
    units
    progress
    zip unzip
    nix-prefetch-git
    ffmpeg-full youtube-dl
    r128gain
    exa
  ];

  programs.direnv.enable = true;
  services.lorri.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    initExtra = ''
      unsetopt BEEP
      . ~/.nix-profile/etc/profile.d/nix.sh
      . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
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
    shellAliases = {
      ls = "exa --icons";
      l = "exa -lah --icons --git";
      la = "exa -la --icons --git";
      ll = "exa -l --icons --git";
      tree = "exa --icons --tree";
      tre = "exa --icons --tree --level=3";
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
  };

  nixpkgs.config.allowUnfree = true;

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
  home.stateVersion = "21.05";
}
