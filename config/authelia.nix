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
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.authelia_smtp_password.path;
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = secrets.authelia_ldap_password.path;
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
          enable_self_enrollment = true;
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
            additional_groups_dn = "ou=groups";
            user = "uid=authelia_bind_user,ou=people,dc=maxwell-lt,dc=dev";
          };
        };
        identity_providers = {
          oidc = {
            authorization_policies = {
              exclude_sa = {
                default_policy = "two_factor";
                rules = [
                  {
                    policy = "deny";
                    subject = "group:service_account";
                  }
                ];
              };
            };
            cors = {
              endpoints = [
                "authorization"
                "token"
                "revocation"
                "introspection"
              ];
              allowed_origins_from_client_redirect_uris = true;
            };
            clients = [
              {
                client_name = "Immich";
                client_id = "cb5ea2da-5e3b-485c-9ca3-9f4383d8a740";
                client_secret = "$pbkdf2-sha512$310000$CgnWht7UOdtIaAJw20YDpA$E.kduTGxMCzCtYp0dNCsNguyXNLWNRgG7y.sv9nidqetx70BQgj.p4nLhadLizXrPafL4RzukZKKyNJaNw4wfA";
                public = false;
                authorization_policy = "exclude_sa";
                redirect_uris = [
                  "https://photos.maxwell-lt.dev/auth/login"
                  "https://photos.maxwell-lt.dev/user-settings"
                  "app.immich:///oauth-callback"
                ];
                scopes = [
                  "openid"
                  "profile"
                  "email"
                ];
              }
              {
                client_name = "Jellyfin";
                client_id = "1f2c0398-be8a-426d-86bc-917f9df5571e";
                client_secret = "$pbkdf2-sha512$310000$of.DVSPmrKmiJIJ8pdDyLA$NtFvpzAHdSBCTXE4vf6SVol5ZvkhIBpBF0cjLsdDKOShw2UhEz/bJBYhf6lnl.LMewaE9LK/DTJQ8tYzD/J8sA";
                public = false;
                authorization_policy = "exclude_sa";
                token_endpoint_auth_method = "client_secret_post";
                redirect_uris = [
                  "https://media.maxwell-lt.dev/sso/OID/redirect/authelia"
                ];
                scopes = [
                  "openid"
                  "groups"
                  "profile"
                ];
              }
              {
                client_name = "Forgejo";
                client_id = "648c896f-54a3-4df5-9740-ea8be50a20b1";
                client_secret = "$pbkdf2-sha512$310000$Mr5fP5vtR9C8TgNF8IlvLg$/KK2zqDMID/xzKi2yP4.yjTVeF43ycPbuX.GbQfIeDLLzsSn2DHYmhQZfpQVYued5dCxsWnIW5BT1OmPaMcu4Q";
                public = false;
                authorization_policy = "exclude_sa";
                token_endpoint_auth_method = "client_secret_basic";
                redirect_uris = [
                  "https://git.maxwell-lt.dev/user/oauth2/authelia/callback"
                ];
                scopes = [
                  "openid"
                  "email"
                  "groups"
                  "profile"
                ];
                userinfo_signed_response_alg = "none";
              }
              {
                client_name = "Argo CD";
                client_id = "5dbafb80-2072-458d-af6a-4ee2358deab7";
                client_secret = "$pbkdf2-sha512$310000$w1nkCqJ4gCvjjNoRdy5KbQ$2krpEnX1fmQnkB3y3Y4ek4yVaUu1hFz1juT/dlo8xP5bFNiBCMeYM0Khey.BK/JxQYYzv27RyJUJC2kSaLNnyA";
                public = false;
                authorization_policy = "exclude_sa";
                redirect_uris = [
                  "https://argocd.kube.maxwell-lt.dev/auth/callback"
                ];
                scopes = [
                  "openid"
                  "email"
                  "groups"
                  "profile"
                ];
                userinfo_signed_response_alg = "none";
              }
              {
                client_name = "Argo CD (CLI)";
                client_id = "argocd-cli";
                public = true;
                authorization_policy = "exclude_sa";
                redirect_uris = [
                  "http://localhost:8085/auth/callback"
                ];
                scopes = [
                  "openid"
                  "email"
                  "groups"
                  "profile"
                  "offline_access"
                ];
                userinfo_signed_response_alg = "none";
              }
              {
                client_name = "Kubernetes";
                client_id = "cbadd492-86d0-445e-93a7-587c6190a386";
                public = true;
                authorization_policy = "exclude_sa";
                redirect_uris = [
                  "http://localhost:8000"
                  "http://localhost:18000"
                ];
                scopes = [
                  "openid"
                  "email"
                  "groups"
                  "profile"
                ];
                userinfo_signed_response_alg = "none";
              }
              {
                client_name = "Coder";
                client_id = "468dc01f-ed54-4976-9f35-9d23fdafee11";
                client_secret = "$pbkdf2-sha512$310000$ZLQK29F6ykFSZ6vXO9/Tcw$wISl78Qr1aAK0zsJdIwvm5M.CTRGS3kmOudvWuTmR.D6y6sSNrUAS05hDi7nT5I1wOTxWFUpJXcgw03GUfd32Q";
                public = false;
                authorization_policy = "exclude_sa";
                redirect_uris = [
                  "https://coder.maxwell-lt.dev/api/v2/users/oidc/callback"
                ];
                scopes = [
                  "openid"
                  "email"
                  "groups"
                  "profile"
                ];
              }
            ];
          };
        };
        access_control = {
          default_policy = "two_factor";
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
          redis = {
            host = "/run/redis-authelia/redis.sock";
          };
          cookies = [
            {
              domain = "maxwell-lt.dev";
              authelia_url = "https://auth.maxwell-lt.dev";
              default_redirection_url = "https://www.maxwell-lt.dev";
            }
          ];
        };
        server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
        notifier.smtp = {
          address = "submission://smtp.gmail.com:587";
          username = "appliedarctan@gmail.com";
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

    systemd.services.authelia-main = {
      serviceConfig.SupplementaryGroups = [ "redis-authelia" ];
      after = [ "redis-immich.service" "lldap.service" "postgresql.service" ];
    };

    networking.firewall.allowedTCPPorts = [ 9091 ];
  };
}
