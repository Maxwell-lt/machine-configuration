{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  playlist-scan = pkgs.writers.writePython3Bin "playlist-scan" { } ''
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
    #playonlinux
    playlist-scan
    hyprpaper
    swaylock-effects
    eww
    playerctl
    libnotify
    bun
    anki
    git-credential-keepassxc
    open-in-mpv
    wl-clipboard
  ];

  programs.ssh = {
    enable = true;
    settings = {
      "library-of-babel" = {
        HostName = "lob.maxwell-lt.dev";
        Port = 22;
        User = "maxwell";
      };

      "library-of-akasha" = {
        HostName = "loa.maxwell-lt.dev";
        Port = 22;
        User = "maxwell";
      };

      "media-server-alpha" = {
        HostName = "10.100.0.2";
        Port = 22;
        User = "maxwell";
      };

      "itg" = {
        HostName = "10.0.0.243";
        Port = 22;
        User = "itg";
      };

      "*" = {
        ForwardAgent = "no";
        AddKeysToAgent = "no";
        Compression = "no";
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = "no";
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
    enableDefaultConfig = false;
  };

  services.playerctld = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    configType = "lua";
    settings =
      let
        lua = lib.generators.mkLuaInline;

        fileManager = "dolphin";
        mainMod = "SUPER";
        menu = "anyrun";
        monLeft = "desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000517";
        monRight = "desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000526";
        monitorConfig = "highrr";
        terminal = "kitty";
      in
      {
        env = [
          {
            _args = [
              "WLR_DRM_NO_ATOMIC"
              "1"
            ];
          }
        ];

        monitor = [
          {
            output = monLeft;
            mode = monitorConfig;
            position = "0x0";
            scale = "1";
          }
          {
            output = monRight;
            mode = monitorConfig;
            position = "2560x0";
            scale = "1";
          }
        ];

        bind = [
          {
            _args = [
              "${mainMod} + T"
              (lua ''hl.dsp.exec_cmd("${terminal}")'')
            ];
          }
          {
            _args = [
              "${mainMod} + C"
              (lua "hl.dsp.window.close()")
            ];
          }
          {
            _args = [
              "${mainMod} + M"
              (lua "hl.dsp.exit()")
            ];
          }
          {
            _args = [
              "${mainMod} + E"
              (lua ''hl.dsp.exec_cmd("${fileManager}")'')
            ];
          }
          {
            _args = [
              "${mainMod} + V"
              (lua ''hl.dsp.window.float({ action = "toggle" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + F"
              (lua ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + R"
              (lua ''hl.dsp.exec_cmd("${menu}")'')
            ];
          }
          {
            _args = [
              "${mainMod} + L"
              (lua ''hl.dsp.exec_cmd("loginctl lock-session")'')
            ];
          }

          {
            _args = [
              "${mainMod} + left"
              (lua ''hl.dsp.focus({ direction = "left" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + right"
              (lua ''hl.dsp.focus({ direction = "right" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + up"
              (lua ''hl.dsp.focus({ direction = "up" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + down"
              (lua ''hl.dsp.focus({ direction = "down" })'')
            ];
          }

          {
            _args = [
              "${mainMod} + XF86AudioPlay"
              (lua ''hl.dsp.focus({ workspace = "name:Music" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + SHIFT + XF86AudioPlay"
              (lua ''hl.dsp.window.move({ workspace = "name:Music" })'')
            ];
          }
          {
            _args = [
              "${mainMod} + Scroll_Lock"
              (lua ''hl.dsp.workspace.toggle_special("name:keepass")'')
            ];
          }

          # Works while locked
          {
            _args = [
              "XF86AudioRaiseVolume"
              (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+")'')
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioLowerVolume"
              (lua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-")'')
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioMute"
              (lua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioPlay"
              (lua ''hl.dsp.exec_cmd("playerctl play-pause")'')
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioPrev"
              (lua ''hl.dsp.exec_cmd("playerctl previous")'')
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioNext"
              (lua ''hl.dsp.exec_cmd("playerctl next")'')
              { locked = true; }
            ];
          }

          # Mouse movement
          {
            _args = [
              "${mainMod} + mouse:272"
              (lua "hl.dsp.window.drag()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "${mainMod} + mouse:273"
              (lua "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              workspace = i + 1;
            in
            [
              {
                _args = [
                  "${mainMod} + ${toString workspace}"
                  (lua "hl.dsp.focus({ workspace = ${toString workspace} })")
                ];
              }
              {
                _args = [
                  "${mainMod} + SHIFT + ${toString workspace}"
                  (lua "hl.dsp.window.move({ workspace = ${toString workspace} })")
                ];
              }
            ]
          ) 9
        ));

        window_rule = [
          {
            match.class = "^(steam_app_)(.*)$";
            immediate = true;
          }
          {
            match.class = "^ITGmania$";
            immediate = true;
          }
          {
            match.class = "^(thunderbird)$";
            float = false;
          }
          {
            match.class = "fcitx";
            pseudo = true;
          }
        ];

        workspace_rule = [
          {
            workspace = "special:keypass";
            on_created_empty = "keepassxc";
          }
        ];

        config = {
          decoration = {
            blur = {
              enabled = true;
              passes = 1;
              size = 3;
              vibrancy = 0.1696;
            };
            rounding = 5;
          };
          general = {
            allow_tearing = true;
            gaps_out = 10;
          };
          input = {
            numlock_by_default = true;
          };
          misc = {
            key_press_enables_dpms = true;
            mouse_move_enables_dpms = true;
          };
        };

        on = [
          {
            _args = [
              "hyprland.start"
              (lua ''
                function()
                  hl.exec_cmd("hyprpaper")
                  hl.exec_cmd("eww daemon; sleep 0.25s; eww open-many leftmon rightmon")
                  hl.exec_cmd("insync start")
                  hl.exec_cmd("fcitx5-remote -r")
                  hl.exec_cmd("fcitx5 -d --replace")
                  hl.exec_cmd("fcitx5-remote -r")
                end'')
            ];
          }
        ];

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
    wallpaper {
      monitor = desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000517
      path = ~/Pictures/wallpapers/Cover.png
    }

    wallpaper {
      monitor = desc:ASUSTek COMPUTER INC VG27AQL3A S4LMQS000526
      path = ~/Pictures/wallpapers/nge6.png
    }
    splash = false
    ipc = off
  '';

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
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libdictionary.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
      width = {
        fraction = 0.3;
      };
      closeOnClick = true;
    };
    extraCss = ''
      window {
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
    extraPackages = with pkgs; [ ];
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
      name = "Breeze";
    };

    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "Breeze";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk4.theme = null;
  };

  qt = {
    enable = true;
    style = {
      name = "Breeze";
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

  systemd.user.services = {
    openrgb-off = {
      Service = {
        ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb -p /home/maxwell/.config/OpenRGB/Off.orp";
        Type = "oneshot";
      };
    };
    openrgb-on = {
      Service = {
        ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb -p /home/maxwell/.config/OpenRGB/Red.orp";
        Type = "oneshot";
      };
    };
  };

  #systemd.user.timers = {
  #  openrgb-off = {
  #    Timer = {
  #      OnCalendar = "22:00:00";
  #      Unit = "openrgb-off.service";
  #    };
  #    Install = {
  #      WantedBy = [ "timers.target" ];
  #    };
  #  };
  #  openrgb-on = {
  #    Timer = {
  #      OnCalendar = "07:00:00";
  #      Unit = "openrgb-on.service";
  #    };
  #    Install = {
  #      WantedBy = [ "timers.target" ];
  #    };
  #  };
  #};

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
