{ config, pkgs, inputs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ../../modules/neovim.nix
  ];

  home.packages = with pkgs; [
    #lutris
    #playonlinux
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
        hostname = "10.100.0.1";
        port = 22;
        user = "maxwell";
      };
      "media-server-alpha" = {
        hostname = "10.100.0.2";
        port = 22;
        user = "maxwell";
      };
      "maxwell-nixos" = {
        hostname = "10.100.0.5";
        port = 22;
        user = "maxwell";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "anyrun";
      "$monitor" = "eDP-1";
      "$monitorConfig" = "highrr";
      monitor = [
        "$monitor, $monitorConfig, 0x0, 1"
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

        "$mainMod, KP_Subtract, togglespecialworkspace, name:keepass"
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
        "eww daemon; sleep 0.25s; eww open-many leftmon"
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
        key_press_enables_dpms = true;
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.swaylock-effects}/bin/swaylock -c 04061f --clock --indicator --grace 10 --grace-no-mouse --fade-in 8";
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
    preload = ~/Pictures/wallpapers/nix-wallpaper.png
    wallpaper = ,~/Pictures/wallpapers/nix-wallpaper.png
    splash = false
    ipc = off
  '';

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = "eDP-1";
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

  programs.kitty = {
    enable = true;
    themeFile = "Solarized_Dark";
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
  home.stateVersion = "23.11";
}
