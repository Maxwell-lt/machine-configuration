{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.mlt.authelia;
  secrets = config.sops.secrets;
  secret_config = {
    mode = "0440";
    owner = "authelia-main";
    group = "authelia-main";
  };
in
{
  options = {
    mlt.authelia = with types; {
      enable = mkEnableOption "Authelia";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      authelia_jwt_secret = secret_config;
      authelia_hmac_secret = secret_config;
      authelia_issuer_priv_key = secret_config;
      authelia_session_secret = secret_config;
      authelia_storage_encryption_key = secret_config;
      authelia_smtp_username = secret_config;
      authelia_smtp_password = secret_config;
      authelia_ldap_password = secret_config;
      authelia_duo_api_key = secret_config;
    };

    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = secrets.authelia_jwt_secret.path;
        oidcHmacSecretFile = secrets.authelia_hmac_secret.path;
        oidcIssuerPrivateKeyFile = secrets.authelia_issuer_priv_key.path;
        sessionSecretFile = secrets.authelia_session_secret.path;
        storageEncryptionKeyFile = secrets.authelia_storage_encryption_key.path;
      };
      environmentVariables = {
        AUTHELIA_NOTIFIER_SMTP_USERNAME_FILE = secrets.authelia_smtp_username.path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.authelia_smtp_password.path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSSWORD_FILE = secrets.authelia_ldap_password.path;
        AUTHELIA_DUO_API_SECRET_KEY_FILE = secrets.authelia_duo_api_key.path;
      };
      settings = {
        theme = "dark";
        default_2fa_method = "totp";
        totp.issuer = "maxwell-lt.dev";
        webauthn.display_name = "auth.maxwell-lt.dev";
        duo_api = {
          hostname = "api-f5e1c025.duosecurity.com";
          integration_key = "DIVEOA4MM83TBMPQ67I5";
        };
        password_policy.zxcvbn.enabled = true;
        authentication_backend = {
          password_reset.disable = false;
          ldap = {
            implementation = "lldap";
            address = "ldap://localhost:3890";
            timeout = "5s";
            start_tls = "false";
            base_dn = "dc=maxwell-lt,dc=dev";
            additional_users_dn = "ou=people";
            users_filter = "(&({username_attribute}={input})(objectClass=person))";
            additional_groups_dn = "ou=groups";
            groups_filter = "(member={dn})";
            user = "cn=authelia_bind_user,dc=maxwell-lt,dc=dev";
          };
        };
        storage = {
          postgres = {
            address = "unix:///run/postgresql";
            database = "authelia-main";
            username = "authelia-main";
            password = "unused"; # uses peer authentication

          };
        };
        session = {
          domain = "maxwell-lt.dev";
          authelia_url = "https://auth.maxwell-lt.dev";
          redis = {
            host = "/run/redis-authelia/redis.sock";
          };
        };
        server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
        notifier = {
          address = "submission://smtp.gmail.com:587";
          sender = "maxwell-lt.dev Auth Server <noreply@auth.maxwell-lt.dev>";
        };
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "authelia-main" ];
      ensureUsers = [
        {
          name = "authelia-main";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };

    services.redis.servers.authelia = {
      enable = true;
      port = 0;
    };

    systemd.services.authelia-main.after = [ "redis-immich.service" "lldap.service" "postgresql.service" ];
  };
}
