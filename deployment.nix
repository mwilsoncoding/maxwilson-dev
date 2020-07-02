{ domain ? "maxwilson.dev" }:
{
  network = {
    description = "maxwilson<dot>dev";
    enableRollback = true;
  };

  resources.gceImages.nixos.sourceUri = (import <nixpkgs/nixos/modules/virtualisation/gce-images.nix>).latest;

  machine =
    { config, pkgs, lib, resources, ... }:
    {
      security.acme.certs."${domain}" = {
        email = "maxwilsondotdev+acmecerts@${domain}";
      };
      services.nginx.enable = true;
      services.nginx.recommendedGzipSettings = true;
      services.nginx.recommendedOptimisation = true;
      services.nginx.recommendedProxySettings = true;
      services.nginx.recommendedTlsSettings = true;
      services.nginx.virtualHosts = {
        "${domain}" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = [ "www.${domain}" ];
          root = "${import ./. {}}";
        };
      };
      networking.firewall.allowedTCPPorts = [ 80 443 ];
      deployment.targetEnv = "gce";
      deployment.gce = {
        region = "us-east1-b";
        bootstrapImage = resources.gceImages.nixos;
        rootDiskSize = 8;
      };
      
    };
}
