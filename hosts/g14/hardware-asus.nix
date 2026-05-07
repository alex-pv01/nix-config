{ pkgs, ... }:
{
  # =============================================================================
  # ASUS-specific software for the G14:
  #   - asusd (asusctl)   → fan curves, charge limits, ROG keys, RGB, profiles
  #   - supergfxd (supergfxctl) → GPU mode (Integrated / Hybrid / dGPU / Vfio)
  #   - fwupd             → BIOS / firmware updates from the LVFS
  #
  # https://gitlab.com/asus-linux/asusctl
  # https://gitlab.com/asus-linux/supergfxctl
  #
  # NOTE: Power profile management uses TuneD (configured in
  # modules/nixos/desktop/power.nix). asusctl integrates with whichever of
  # TuneD / power-profiles-daemon is active, so we do NOT enable PPD here.
  # =============================================================================

  services.asusd.enable = true;
  # NOTE: services.asusd.enableUserService was removed upstream — the user
  # service is no longer needed. asusctl talks to the system daemon directly.

  services.supergfxd.enable = true;

  # Convenience CLIs available system-wide.
  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
  ];

  # BIOS / firmware updates.
  services.fwupd.enable = true;

  # ---------------------------------------------------------------------------
  # First-boot manual setup (not declarative; do once after first install):
  # ---------------------------------------------------------------------------
  #   # GPU mode: Integrated for max battery, Hybrid for occasional dGPU use.
  #   # Hybrid is also fine — PRIME offload only wakes the dGPU when needed.
  #   sudo supergfxctl -m Integrated
  #
  #   # Stop keyboard LED flashing during sleep.
  #   asusctl led-mode sleep-enable false
  #
  #   # Set a battery charge limit to extend battery longevity.
  #   # 80% recommended if the laptop is mostly plugged in.
  #   asusctl -c 80
  #
  # State written by these commands lives in /etc/asusd/, /var/lib/asusd/,
  # and /etc/supergfxd.conf — covered by preservation.nix.

  # ---------------------------------------------------------------------------
  # Fingerprint reader (optional — verify your G14 variant has the sensor).
  # ---------------------------------------------------------------------------
  # On the G14, run `lsusb` and look for a Goodix or Synaptics device.
  # If present, uncomment and `nixos-rebuild switch`, then enrol with
  # `fprintd-enroll` and integrate with PAM (e.g. for sudo / login).
  #
  # services.fprintd.enable = true;
}
