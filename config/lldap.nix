{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.mlt.lldap;
  secrets = config.sops.secrets;
in
{
  options = {
    mlt.lldap = with types; {
      enable = mkEnableOption "LLDAP";
    };
  };

  config = mkIf cfg.enable {
    services.lldap = {
      enable = true;
      settings = {
        http_url = "https://ldap.maxwell-lt.dev";
        ldap_base_dn = "dc=maxwell-lt,dc=dev";
        database_url = "postgres:///lldap";
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = secrets.lldap_jwt_secret.path;
        LLDAP_LDAP_USER_PASS_FILE = secrets.lldap_user_pass.path;
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "lldap" ];
      ensureUsers = [
        {
          name = "lldap";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };
  };
}
