{ lib, config, ... }:

with lib;
let
  cfg = config.mlt.forgejo;
in
{
  options = {
    mlt.forgejo = with types; {
      enable = mkEnableOption "Forgejo";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database = {
        type = "postgres";
        socket = "/run/postgresql";
      };
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "git.maxwell-lt.dev";
          ROOT_URL = "https://git.maxwell-lt.dev";
        };
        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          REQUIRE_SIGNIN_VIEW = true;
        };
        openid = {
          ENABLE_OPENID_SIGNIN = true;
          ENABLE_OPENID_SIGNUP = true;
          WHITELISTED_URIS = "auth.maxwell-lt.dev";
        };
        session = {
          PROVIDER = "db";
          COOKIE_SECURE = true;
        };
        webhook = {
          ALLOWED_HOST_LIST = "loopback";
        };
      };
    };
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "forgejo" ];
      ensureUsers = [
        {
          name = "forgejo";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];
  };
}
