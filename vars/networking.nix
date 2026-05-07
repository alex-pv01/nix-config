{ lib }:
rec {
  # Default gateway for static-IP hosts. Override per-host if needed.
  # For laptops on DHCP this is unused.
  mainGateway = "192.168.1.1";
  mainGateway6 = "fe80::1";
  proxyGateway = mainGateway;
  proxyGateway6 = mainGateway6;

  nameservers = [
    # IPv4
    "1.1.1.1" # Cloudflare
    "9.9.9.9" # Quad9
    # IPv6
    "2606:4700:4700::1111" # Cloudflare
    "2620:fe::fe" # Quad9
  ];
  prefixLength = 24;

  # Static-IP table — only populate for hosts that actually use static IPs.
  # Laptops typically use DHCP and don't need an entry here. Currently empty;
  # add an entry when you have a host that wants a static IP, e.g.:
  #
  #   hostsAddr = {
  #     myserver = {
  #       iface = "enp1s0";
  #       ipv4 = "192.168.1.10";
  #       ipv6 = "fe80::10";  # optional
  #     };
  #   };
  hostsAddr = { };

  hostsInterface = lib.attrsets.mapAttrs (key: val: {
    interfaces."${val.iface}" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          inherit prefixLength;
          address = val.ipv4;
        }
      ];
    };
  }) hostsAddr;

  ssh = {
    # Written to /etc/ssh/ssh_config — host aliases for `ssh ai` etc.
    extraConfig = (
      lib.attrsets.foldlAttrs (
        acc: host: val:
        acc
        + ''
          Host ${host}
            HostName ${val.ipv4}
            Port 22
        ''
      ) "" hostsAddr
    );

    # Written to /etc/ssh/ssh_known_hosts — pre-trusted SSH host keys.
    # Add your own machines' /etc/ssh/ssh_host_ed25519_key.pub values here.
    knownHosts = lib.attrsets.mapAttrs
      (host: value: {
        hostNames = [ host ] ++ (lib.optional (hostsAddr ? host) hostsAddr.${host}.ipv4);
        publicKey = value.publicKey;
      })
      {
        # GitHub's host key — verifies SSH clones/pulls/pushes.
        # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
        "github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
  };
}
