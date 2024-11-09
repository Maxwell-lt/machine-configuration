# Imports all modules in the config/ directory. This module should be included in all top-level system configurations.
{
  imports = [
    # General options
    ./common.nix                # Options that will be enabled on most systems
    ./desktop.nix               # Options that will be enabled on desktop systems
    ./docker.nix                # Enable docker daemon
    ./vm.nix                    # Enable tools for working with VMs
    ./zfs.nix                   # Enable ZFS filesystem support
    ./openrgb.nix               # Enable OpenRGB software

    # Services
    ./powerpanel.nix            # CyberPower PowerPanel software
    ./powerpanel-exporter.nix   # Custom Prometheus exporter which reads data from PowerPanel
    ./zpool-exporter.nix        # Custom Prometheus exporter which queries disk usage information from ZFS
    ./jellyfin.nix              # Jellyfin media server
    ./photoprism.nix            # PhotoPrism photo management server
    ./nextcloud.nix             # NextCloud
    ./lldap.nix                 # Light LDAP
  ];
}
