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
    sops.secrets.lldap_jwt_secret = {
      mode = "0440";
      group = "lldap-secrets";
    };
    sops.secrets.lldap_user_pass = {
      mode = "0440";
      group = "lldap-secrets";
    };

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

    users.groups = {
      lldap-secrets = { };
    };

    systemd.services.lldap.serviceConfig.SupplementaryGroups = [ "lldap-secrets" ];

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
