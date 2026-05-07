{ mylib, ... }:
{
  # Auto-import any *.nix files / subdirectories added here.
  # Use this for G14-specific knobs that don't belong in the generic
  # hardware-* files: e.g. custom systemd timers, host-specific overlays,
  # bespoke scripts. Empty for now.
  imports = mylib.scanPaths ./.;
}
