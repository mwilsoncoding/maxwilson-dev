{ nixpkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/1dc37370c489b610f8b91d7fdd40633163ffbafd.tar.gz") {}
}:

let
  domain = "maxwilson.dev";
in

{
  network = {
    description = "maxwilson<dot>dev";
    enableRollback = true;
  };

  resources.gceImages.nixos.sourceUri = (import <nixpkgs/nixos/modules/virtualisation/gce-images.nix>).latest;

  resources.gceStaticIPs.site-ingress-static-ip = {
      region = "us-central1";
  };
      
  cluster-node-0 = { config, resources, ... }: {
    # Configure main ingress at this level since you have access to what containers exist
    containers.site-i.config =
      let
        cluster-config = config;
      in
      { config, pkgs, lib, resources, ... }:
      {
#        security.acme.email = "maxwilsondotdev+acmecerts@${domain}";
        networking.firewall.allowedTCPPorts = [ 80 443 ];
        services.nginx.enable = true;
        services.nginx.recommendedGzipSettings = true;
        services.nginx.recommendedOptimisation = true;
        services.nginx.recommendedProxySettings = true;
#        services.nginx.recommendedTlsSettings = true;
        services.nginx.virtualHosts.site-i = {
#          forceSSL = true;
#          enableACME = true;
          serverAliases = [ "www.${domain}" ];
          locations."/" = {
            proxyPass = "http://site-upstream";
          };
        };
        services.nginx.upstreams.site-upstream.servers = {
          "${cluster-config.containers.site-0.localAddress}" = {};
        };
      };
    containers.site-i.forwardPorts = [{hostPort = 80;} {hostPort = 443;}];
    containers.site-i.privateNetwork = true;
    containers.site-i.localAddress = resources.gceStaticIPs.site-ingress-static-ip.publicIPv4;
    containers.site-i.hostAddress = "10.120.0.4";
    containers.site-i.autoStart = true;
    containers.site-0.config = { pkgs, lib, resources, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 80 ];
      services.nginx.enable = true;
      services.nginx.recommendedGzipSettings = true;
      services.nginx.recommendedOptimisation = true;
      services.nginx.recommendedProxySettings = true;
      services.nginx.recommendedTlsSettings = true;
      services.nginx.virtualHosts.site-0 = {
          root = "${import ./. {}}";
      };
    };
    containers.site-0.autoStart = true;
    containers.site-0.privateNetwork = true;
    containers.site-0.localAddress = "10.120.0.3";
    containers.site-0.hostAddress = "10.120.0.2";
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    deployment.targetEnv = "gce";
    deployment.gce = {
      region = "us-central1-c";
      bootstrapImage = resources.gceImages.nixos;
      rootDiskSize = 4;
    };
  };
}
