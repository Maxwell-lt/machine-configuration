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
    swaylock-effects
    eww
    playerctl
    libnotify
    bun
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
      "itg" = {
        hostname = "10.0.0.243";
        port = 22;
        user = "itg";
      };
    };
  };

  services.playerctld = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "anyrun";
      "$monLeft" = "ASUSTek COMPUTER INC VG27AQL3A S4LMQS000526";
      "$monRight" = "ASUSTek COMPUTER INC VG27AQL3A S4LMQS000517";
      "$monitorConfig" = "highrr";
      monitor = [
        "$monLeft, $monitorConfig, 0x0, 1"
        "$monRight, $monitorConfig, 2560x0, 1"
      ];
      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, J, togglesplit, # dwindle"
        "$mainMod, L, exec, loginctl lock-session"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"

        "$mainMod, XF86AudioPlay, workspace, name:Music"
        "$mainMod SHIFT, XF86AudioPlay, movetoworkspace, name:Music"

        "$mainMod, Scroll_Lock, togglespecialworkspace, name:keepass"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];
      exec-once = [
        "hyprpaper"
        "eww daemon; sleep 0.25s; eww open-many leftmon rightmon"
        "insync start"
        "fcitx5-remote -r"
        "fcitx5 -d --replace"
        "fcitx5-remote -r"
      ];
      workspace = [
        "special:keepass, on-created-empty:keepassxc"
      ];
      general = {
        allow_tearing = true;
        gaps_out = 10;
      };
      env = [
        "WLR_DRM_NO_ATOMIC, 1"
      ];
      windowrulev2 = [
        "immediate, class:^(steam_app_)(.*)$"
        "immediate, class:^ITGmania$"
        "tile, class:^(thunderbird)$"
        "pseudo,class:fcitx"
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
      input = {
        numlock_by_default = true;
      };
      misc = {
        mouse_move_enables_dpms = true;
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.swaylock-effects}/bin/swaylock -c 04061f --clock --indicator";
      };
      listener = [
        {
          timeout = 900;
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 1800;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        }
      ];
    };
  };

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/wallpapers/Cover.png
    preload = ~/Pictures/wallpapers/nge6.png
    wallpaper = desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000526,~/Pictures/wallpapers/Cover.png
    wallpaper = desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000517,~/Pictures/wallpapers/nge6.png
    splash = false
    ipc = off
  '';

  programs.waybar = {
    enable = false;
    systemd = {
      enable = false;
      target = "hyprland-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "tray" "wireplumber" "clock" ];
        tray = {
          icon-size = 20;
          spacing = 10;
        };
        wireplumber = {
          format = "{volume}%";
          max-volume = 100;
          scroll-step = 1;
        };
        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
        };
        "hyprland/workspaces" = {
          format = "{name} {windows}";
          format-window-separator = " ";
          window-rewrite-default = "";
          window-rewrite = {
            "class<kitty>" = "";
            "class<firefox>" = "";
            "class<org.strawberrymusicplayer.strawberry>" = "";
          };
        };
      };
    };
    style = ''
      * {
        font-family: Hack Nerd Font;
      }
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = "DP-1";
        font = "Hack Nerd Font 10";
        format = "<b>%s</b>\\n<i>%a</i>\\n\\n%b";
        history_length = 100;
        corner_radius = 5;
        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_current";
        mouse_middle_click = "close_all";
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
      width = { fraction = 0.3; };
      closeOnClick = true;
    };
    extraCss = ''
      #window {
        background-color: rgba(0, 0, 0, 0);
        background-image: radial-gradient(ellipse 70% 50% at top,
          rgba(200, 255, 200, 0.6),
          rgba(200, 200, 255, 0.6)
        );
      }
    '';
  };

  home.file.".config/eww" = {
    source = ../../modules/eww;
    recursive = true;
  };

  programs.ags = {
    enable = true;
    configDir = ../../modules/ags;
    extraPackages = with pkgs; [];
  };

  programs.kitty = {
    enable = true;
    theme = "Solarized Dark";
    font = {
      name = "Hack Nerd Font";
      size = 10;
    };
    shellIntegration.enableZshIntegration = true;
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
      package = pkgs.kdePackages.breeze-gtk;
      name = "Breeze-Dark";
    };

    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "Breeze";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  qt = {
    enable = true;
    style = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze;
    };
    platformTheme.name = "kde";
  };

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    enable = true;
    history = {
      size = 60000;
      expireDuplicatesFirst = true;
      extended = true;
      path = "$HOME/.histfile";
    };
    autosuggestion = {
      enable = true;
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
