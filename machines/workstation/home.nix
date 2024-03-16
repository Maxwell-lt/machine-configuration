{ config, pkgs, inputs, ... }:

let
  playlist-scan = pkgs.writers.writePython3Bin "playlist-scan" {} ''
    import os
    import sys
    with open(sys.argv[1]) as f:
        lines = f.read().splitlines()
    miss = [line for line in lines if line[0] != '#' and not os.path.exists(line)]
    print(f'Playlist {sys.argv[1]} has {len(miss)} missing files.')
    print(*miss, sep='\n')
  '';
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  manual.manpages.enable = false;

  imports = [
    ../../modules/neovim.nix
  ];

  home.packages = with pkgs; [
    #lutris
    playonlinux
    playlist-scan
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "library-of-babel" = {
        hostname = "ssh.maxwell-lt.dev";
        port = 22;
        user = "maxwell";
      };
      "media-server-alpha" = {
        hostname = "10.0.0.114";
        port = 22;
        user = "maxwell";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [ hyprbars ];
    settings = {
      monitor = [
        "DP-1, 2560x1440@144, 0x0, 1"
        "DP-2, 2560x1440@144, 2560x0, 1"
      ];
      bind = [
        "SUPER,T,exec,konsole"
      ];
      bindl = [
        "XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
        "XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
        "XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      exec-once = [
        "waybar"
      ];
      general = {
        allow_tearing = true;
      };
      env = [
        "WLR_DRM_NO_ATOMIC, 1"
      ];
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
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
