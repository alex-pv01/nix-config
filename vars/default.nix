{ lib }:
{
  username = "alex";
  userfullname = "Alex Pujol";
  useremail = "alex-pv01@proton.me";
  networking = import ./networking.nix { inherit lib; };

  # Generated using: mkpasswd -m yescrypt --rounds=11
  # https://man.archlinux.org/man/crypt.5.en
  #
  # TODO: replace this placeholder before first install. Steps:
  #   1. nix-shell -p mkpasswd
  #   2. mkpasswd -m yescrypt --rounds=11
  #   3. paste the resulting hash here.
  # The placeholder below is a hash of the literal string "changeme" — DO NOT
  # ship a machine to anyone with this in place.
  initialHashedPassword = "$y$j9T$aSEmYNWLIKHsUQwT4RZIA0$3xkJqIOMYS7ApPP4Ef.5K3JGRfb/a7bLWZmv8HZIdWB";

  # Public keys that can SSH into every host built from this flake.
  #
  # Generate the matching private key locally on each trusted client with:
  #   ssh-keygen -t ed25519 -a 256 -C "alex@<hostname>"
  # The private key must never leave the device.
  #
  # TODO: add your real public keys here before first install. Leaving an
  # empty list means no remote SSH access by key — only local console login.
  mainSshAuthorizedKeys = [
    # "ssh-ed25519 AAAA... alex@g14"
  ];

  # Backup SSH keys for disaster recovery.
  secondaryAuthorizedKeys = [
    # "ssh-ed25519 AAAA... alex@recovery"
  ];
}
