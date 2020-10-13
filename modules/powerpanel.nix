{ config, lib, pkgs, options, ... }:

with lib;
{
  options = {
    services.powerpanel = with types; {
      enable = mkEnableOption "powerpanel";

      package = mkOption {
        description = "powerpanel package";
        defaultText = "pkgs.powerpanel";
        type = package;
        default = pkgs.callPackage ../powerpanel {};
      };

      powerfail = {
        delay = mkOption {
          description = "Delay time in seconds since power failure before running script";
          example = 60;
          type = int;
          default = 60;
        };

        scriptEnable = mkOption {
          description = "Whether to run the script";
          type = bool;
          example = true;
          default = true;
        };
        
        scriptText = mkOption {
          description = "Script to run when a power failure is detected";
          type = str;
          default = "";
        };

        scriptWaitTime = mkOption {
          description = "Time in seconds to wait for script to run before shutdown is triggered";
          type = int;
          example = 5;
          default = 5;
        };

        autoShutdown = mkOption {
          description = "Automatically shutdown system after running script";
          example = true;
          type = bool;
          default = true;
        };
      };
      
      lowbatt = {
        delay = mkOption {
          description = "Delay time in seconds since battery threshold reached before running script";
          example = 60;
          type = int;
          default = 60;
        };

        scriptEnable = mkOption {
          description = "Whether to run the script";
          type = bool;
          example = true;
          default = true;
        };

        scriptText = mkOption {
          description = "Script to run when a low battery is detected";
          type = str;
          default = "";
        };

        scriptWaitTime = mkOption {
          description = "Time in seconds to wait for script to run before shutdown is triggered";
          type = int;
          example = 5;
          default = 5;
        };

        autoShutdown = mkOption {
          description = "Automatically shutdown system after running script";
          example = true;
          type = bool;
          default = true;
        };

        lowbattThreshold = mkOption {
          description = "Battery capacity percentage at which the lowbatt event should be triggered. Range is 0 ~ 90";
          example = 50;
          type = int;
          default = 35;
        };

        runtimeThreshold = mkOption {
          description = "Runtime in seconds at which the lowbatt event should be triggered. Range is 0 ~ 3600";
          example = 600;
          type = int;
          default = 300;
        };
      };

      enableAlarm = mkOption {
        description = "Turn UPS alarm on";
        example = true;
        type = bool;
        default = true;
      };

      shutdownSustain = mkOption {
        description = "The necessary time in seconds for system shutdown. The UPS will turn power off when this time is expired. Range is 0 ~ 3600";
        example = 600;
        type = int;
        default = 600;
      };

      turnUPSOff = mkOption {
        description = "Whether the UPS should turn off after triggering a system shutdown";
        example = true;
        type = bool;
        default = true;
      };

      pollingRate = mkOption {
        description = "Frequency of polling the UPS in seconds. Range is 1 ~ 60";
        example = 15;
        type = int;
        default = 3;
      };

      retryRate = mkOption {
        description = "Frequency of retrying connection to UPS if unable to connect. Range is 1 ~ 300";
        example = 10;
        type = int;
        default = 10;
      };

      prohibitClientAccess = mkOption {
        description = "Prevent the pwrstat client from communicating with the daemon";
        example = true;
        type = bool;
        default = false;
      };

      allowedDeviceNodes = mkOption {
        description = ''
          Which interfaces the daemon is allowed to use to connect to the UPS.
          The available interfaces are 'ttyS', 'ttyUSB', 'hiddev', and 'libusb'. By default, the daemon will use all device nodes automatically.
          Providing a list of device nodes here will restrict the daemon.

          Example: restrict to ttyS1, ttyS2, and hiddev1 at /dev:
            "/dev/ttyS1;/dev/ttyS2;/dev/hiddev1"

          Example: restrict to all ttyS and ttyUSB nodes:
            "ttyS;ttyUSB"

          Example: restrict to use hiddev group at /dev, /dev/usb, and /dev/usb/hid:
            "hiddev"

          Example: restrict to libusb device:
            "libusb"


          Leave this option blank to allow all device nodes.
        '';
        example = "ttyUSB;libusb";
        type = str;
        default = "";
      };

      hibernate = mkOption {
        description = "Hibernate instead of shutting down the system when a power event is trigggered";
        example = false;
        type = bool;
        default = false;
      };
    };
  };

  config = let 
    cfg = config.services.powerpanel;
    powerfailCmd = pkgs.writeScriptBin "pwrstatd-powerfail" ''
      ${cfg.powerfail.scriptText}
    '';
    lowbattCmd = pkgs.writeScriptBin "pwrstatd-lowbatt" ''
      ${cfg.lowbatt.scriptText}
    '';
    yesNo = val: if val then "yes" else "no";
  in
  mkIf cfg.enable {
    systemd.services.powerpanel = {
      enable = cfg.enable;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/pwrstatd \
        '';
      };
    };

    environment.etc."pwrstatd.conf".text = ''
      powerfail-delay = ${builtins.toString cfg.powerfail.delay}
      powerfail-active = ${yesNo cfg.powerfail.scriptEnable}
      powerfail-cmd-path = ${powerfailCmd}/bin/pwrstatd-powerfail
      powerfail-duration = ${builtins.toString cfg.powerfail.scriptWaitTime}
      powerfail-shutdown = ${yesNo cfg.powerfail.autoShutdown}

      lowbatt-threshold = ${builtins.toString cfg.lowbatt.lowbattThreshold}
      runtime-threshold = ${builtins.toString cfg.lowbatt.runtimeThreshold}
      lowbatt-active = ${yesNo cfg.lowbatt.scriptEnable}
      lowbatt-cmd-path = ${lowbattCmd}/bin/pwrstatd-lowbatt
      lowbatt-duration = ${builtins.toString cfg.lowbatt.scriptWaitTime}
      lowbatt-shutdown = ${yesNo cfg.lowbatt.autoShutdown}

      enable-alarm = ${yesNo cfg.enableAlarm}
      shutdown-sustain = ${builtins.toString cfg.shutdownSustain}
      turn-ups-off = ${yesNo cfg.turnUPSOff}
      ups-polling-rate = ${builtins.toString cfg.pollingRate}
      ups-retry-rate = ${builtins.toString cfg.retryRate}
      prohibit-client-access = ${yesNo cfg.prohibitClientAccess}
      allowed-device-nodes = ${cfg.allowedDeviceNodes}
      hibernate = ${yesNo cfg.hibernate}
    '';

    environment.systemPackages = [
      (cfg.package)
    ];
  };
}
