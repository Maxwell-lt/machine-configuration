{ config, pkgs, ... }:

let
  breezy = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "breezy";
    version = "2020-03-24";
    src = pkgs.fetchFromGitHub {
      owner = "fneu";
      repo = "breezy";
      rev = "453167dc346f39e51141df4fe7b17272f4833c2b";
      sha256 = "09w4glff27sw4z2998gpq5vmlv36mfx9vp287spm7xvaq9fnn6gb";
    };
  };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    #lutris
    playonlinux
    ripgrep
  ];

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  nixpkgs.config.allowUnfree = true;

    programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      extraConfig = ''
        filetype plugin indent on
	syntax on
	set backspace=indent,eol,start
	set hidden
	set nobackup
	set nowritebackup
	set noswapfile
	set cmdheight=2
	set updatetime=300
        set shortmess+=c
        colorscheme breezy
        set background=light

        let g:lightline = {
          \ 'colorscheme': 'breezy',
          \ 'component': {
          \   'readonly': '%{&readonly?"":""}',
          \ },
          \ 'separator': { 'left': '', 'right': '' },
          \ 'subseparator': { 'left': '', 'right': '' }
          \ }
       '';
      plugins = with pkgs.vimPlugins; [
        lightline-vim coc-nvim vim-nix fzf-vim coc-fzf fzfWrapper breezy
      ];
    };
    fzf = {
      enable = true;
      defaultCommand = "rg --files --no-ignore-vcs --hidden";
    };
  };

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
