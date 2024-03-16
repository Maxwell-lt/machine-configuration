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
    hyprpaper
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
      "$mainMod" = "SUPER";
      "$terminal" = "konsole";
      "$fileManager" = "dolphin";
      "$menu" = "anyrun";
      "$monLeft" = "AOC Q27G1WG4 0x00019CE9";
      "$monRight" = "AOC Q27G1WG4 0x00018D10";
      monitor = [
        "$monLeft, 2560x1440@144, 0x0, 1"
        "$monRight, 2560x1440@144, 2560x0, 1"
      ];
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, J, togglesplit, # dwindle"
        "$mainMod, L, exec, swaylock -c 04061f"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      exec-once = [
        "dunst & waybar"
        "hyprpaper"
      ];
      general = {
        allow_tearing = true;
      };
      env = [
        "WLR_DRM_NO_ATOMIC, 1"
      ];
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };
      plugin = {
        hyprbars = {
          bar_height = 20;
          hyprbars-button = [
            "rgb(ff4040), 10, 󰖭, hyprctl dispatch killactive"
            "rgb(eeee11), 10, , hyprctl dispatch fullscreen 1"
          ];
        };
      };
    };
  };

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/wallpapers/Cover.png
    preload = ~/Pictures/wallpapers/nge6.png
    wallpaper = desc:AOC Q27G1WG4 0x00019CE9,~/Pictures/wallpapers/nge6.png
    wallpaper = desc:AOC Q27G1WG4 0x00018D10,~/Pictures/wallpapers/Cover.png
    ipc = off
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-center = [ "hyprland/window" ];
      };
    };
  };

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        dictionary
        rink
        symbols
        translate
        websearch
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
      package = pkgs.libsForQt5.breeze-gtk;
      name = "Breeze Dark";
    };

    iconTheme = {
      package = pkgs.libsForQt5.breeze-icons;
      name = "Breeze";
    };

    font = {
      name = "Noto Sans";
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
