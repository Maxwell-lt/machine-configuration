{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ../../modules/neovim.nix
  ];

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  nixpkgs.config.allowUnfree = true;

  home.file.".zshrc".text = ''
    # Lines configured by zsh-newuser-install
    HISTFILE=~/.histfile
    HISTSIZE=1000
    SAVEHIST=1000
    setopt appendhistory autocd notify
    unsetopt beep
    bindkey -e
    # End of lines configured by zsh-newuser-install
    # The following lines were added by compinstall
    zstyle :compinstall filename '/home/maxwell/.zshrc'

    autoload -Uz compinit
    compinit
    # End of lines added by compinstall
    eval "$(direnv hook zsh)"
    export EDITOR="nvim"
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
  '';

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
