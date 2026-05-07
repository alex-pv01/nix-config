{
  # Inherit NixOS's default networking.timeServers (*.nixos.pool.ntp.org —
  # globally geo-routed). No override needed for a laptop in Europe.

  # dynamically update /etc/hosts for testing
  # Note that changes made in this way will be discarded when switching configurations.
  environment.etc.hosts.mode = "0644";
}
