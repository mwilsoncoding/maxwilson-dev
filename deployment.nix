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
      
  cluster-node-0 = { config, resources, lib, ... }: {
    # Configure main ingress at this level since you have access to what containers exist
    containers.site-i.config =
      let
        inherit resources;
      in
      { config, pkgs, lib, ... }:
      {
#        security.acme.email = "maxwilsondotdev+acmecerts@${domain}";
        networking.firewall.allowedTCPPorts = [ 80 443 ];
        networking.interfaces.mv-eth1.ipv4.addresses = [ { address = "10.0.1.3"; prefixLength = 24; } ];
        services.nginx.enable = true;
        services.nginx.recommendedGzipSettings = true;
        services.nginx.recommendedOptimisation = true;
        services.nginx.recommendedProxySettings = true;
        services.nginx.recommendedTlsSettings = true;
        services.nginx.virtualHosts.site-i = {
#          forceSSL = true;
#          enableACME = true;
          serverAliases = [ "www.${domain}" "${domain}" ];
          locations."/" = {
            proxyPass = "http://site-upstream";
          };
        };
        services.nginx.upstreams.site-upstream.servers = {
          site-0 = {};
        };
      };
    #containers.site-i.forwardPorts = [{hostPort = 80;} {hostPort = 443;}];
    containers.site-i.autoStart = true;
    containers.site-i.macvlans = [ "eth1" ];
    containers.site-0.config = { pkgs, lib, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 80 ];
      networking.interfaces.mv-eth1.ipv4.addresses = [ { address = "10.0.1.2"; prefixLength = 24; } ];
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
    containers.site-0.macvlans = [ "eth1" ];
    #containers.site-0.privateNetwork = true;
    #containers.site-0.hostBridge = "br0";
    #containers.site-0.localAddress = "10.0.1.2";
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.macvlans.mv-eth1-host = {
      interface = "eth1";
      mode = "bridge";
    };
    networking.interfaces.eth1.ipv4.addresses = lib.mkForce [];
    networking.interfaces.eth1.virtual = true;
    networking.interfaces.mv-eth1-host.ipv4.addresses = [ { address = "10.0.1.1"; prefixLength = 24; } ];
    networking.interfaces.mv-eth1-host.virtual = true;
    #networking.bridges.br0.interfaces = [];
    #networking.interfaces.br0.ipv4.addresses = [ { address = "10.0.1.1"; prefixLength = 24; } ];
    deployment.targetEnv = "gce";
    deployment.gce = {
      region = "us-central1-c";
      bootstrapImage = resources.gceImages.nixos;
      rootDiskSize = 4;
    };
  };
}
