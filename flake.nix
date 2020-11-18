{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/1dc37370c489b610f8b91d7fdd40633163ffbafd;
  inputs.maxwilsonDevSiteContainerConfig.url = github:NixOS/nixpkgs/1dc37370c489b610f8b91d7fdd40633163ffbafd;

  outputs = { self, nixpkgs, maxwilsonDevSiteContainerConfig }:

    let
      domain = "maxwilson.dev";
      region = "us-central1-c";
    in

    {
      nixopsConfigurations.maxwilsonDev = {

        inherit nixpkgs;

        network = {
          description = "maxwilson<dot>dev";
          enableRollback = true;
        };

        resources.gceImages.nixos.sourceUri = (import <nixpkgs/nixos/modules/virtualisation/gce-images.nix>).latest;

        resources.gceStaticIPs.siteIngressStatcIP = {};
      
        clusterNode0 = { resources, ... }: {
          # Configure main ingress at this level since you have access to what containers exist
#          containers.siteIngress.config = { config, pkgs, lib, resources, ... }:
#          {
##            security.acme.email = "maxwilsondotdev+acmecerts@${domain}";
#            networking.firewall.allowedTCPPorts = [ 80 443 ];
#            services.nginx.enable = true;
#            services.nginx.recommendedGzipSettings = true;
#            services.nginx.recommendedOptimisation = true;
#            services.nginx.recommendedProxySettings = true;
##            services.nginx.recommendedTlsSettings = true;
#            services.nginx.virtualHosts."${domain}" = {
##              forceSSL = true;
##              enableACME = true;
#              serverAliases = [ "www.${domain}" ];
#              locations."/" = {
#                proxyPass = "http://siteUpstream";
#              };
#            };
#            services.nginx.upstreams.siteUpstream.servers = {
#              siteContainer0 = {};
#            };
#          };
#          containers.siteIngress.forwardPorts = [{hostPort = 80;} {hostPort = 443;}];
#          containers.siteIngress.hostAddress = resources.gceStaticIPs.siteIngressStaticIP.publicIPv4;
#          containers.siteIngress.autoStart = true;
          containers.siteContainer0.config = maxwilsonDevSiteContainerConfig;
          containers.siteContainer0.autoStart = true;
          networking.firewall.allowedTCPPorts = [ 80 443 ];
          deployment.targetEnv = "gce";
          deployment.gce = {
            inherit region;
            bootstrapImage = resources.gceImages.nixos;
            rootDiskSize = 4;
          };
        };
      };
    };
}