{config, pkgs, lib, ...}:

{
  virtualisation = {
    oci-containers = {
      backend = lib.mkDefault "podman";
      containers = {
        "grocy" = {
          image = "ghcr.io/linuxserver/grocy";
          volumes = [
            "/srv/containers/grocy:/config"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "America/Detroit";
            GROCY_FEATURE_FLAG_TASKS = "false";
            GROCY_FEATURE_FLAG_BATTERIES = "false";
            GROCY_FEATURE_FLAG_EQUIPMENT = "false";
          };
          autoStart = true;
          extraOptions = [ "--pod=grocy-pod" ];
        };
      };
    };
  };

  systemd.services."podman-grocy".after = [ "create-grocy-pod.service" ];

  systemd.services.create-grocy-pod = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "podman-grocy.service"
    ];
    path = [ pkgs.zfs ];
    script = with pkgs; ''
      ${podman}/bin/podman pod exists grocy-pod || \
        ${podman}/bin/podman pod create --name grocy-pod -p '0.0.0.0:9280:80'
    '';
  };
}
