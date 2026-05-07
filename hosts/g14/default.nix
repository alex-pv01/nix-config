{
  inputs,
  lib,
  ...
}:
#############################################################
#
#  g14 — ASUS Zephyrus G14 (2021, GA401Q*) laptop.
#  AMD Ryzen 5/7/9 5000 series + Radeon Vega iGPU + NVIDIA RTX dGPU.
#
#  Storage layout: vanilla NixOS install (ext4 root, no LUKS, no
#  impermanence). The disko + tmpfs + preservation pattern from idols-ai is
#  intentionally NOT used here.
#
#  Boot loader: systemd-boot (configured in hardware-configuration.nix).
#  Networking : NetworkManager + DHCP (laptops switch networks).
#
#  ---------------------------------------------------------------------
#  Deliberately NOT imported here (vs. idols-ai), and where to find them:
#  ---------------------------------------------------------------------
#    disko + ./disko-fs.nix      → would declare partitions; needs a
#                                  re-install to adopt. Template:
#                                  `git show pre-strip-upstream:hosts/idols-ai/disko-fs.nix`
#    ./preservation.nix          → impermanence (tmpfs root + bind-mounts).
#                                  Same constraint — needs a re-install.
#                                  Template: same path on pre-strip-upstream.
#    ./secureboot.nix            → lanzaboote Secure Boot. Can be added
#                                  later without re-install. Template:
#                                  `git show pre-strip-upstream:hosts/idols-ai/secureboot.nix`
#
#  See ARCHIVE.md → "Design choices for the g14 host" for the full rationale.
#
#############################################################
let
  hostName = "g14";
in
{
  imports = [
    # nixos-hardware profile for the GA401 chassis (ASUS Zephyrus G14 2021).
    # Provides sensible defaults for power, thermals, and audio quirks.
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401

    # Hardware scan results — paste the contents of /etc/nixos/hardware-configuration.nix
    # from the live G14 install into ./hardware-configuration.nix here.
    ./hardware-configuration.nix

    ./hardware-amd.nix
    ./hardware-nvidia.nix
    ./hardware-asus.nix

    # Host-specific extras (auto-imported via mylib.scanPaths).
    ./g14
  ];

  networking = {
    inherit hostName;
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  # Locale, keyboard, timezone — Catalonia / Spain.
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "ca_ES.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "ca_ES.UTF-8";
    LC_MEASUREMENT = "ca_ES.UTF-8";
    LC_PAPER = "ca_ES.UTF-8";
    LC_NUMERIC = "ca_ES.UTF-8";
    LC_MONETARY = "ca_ES.UTF-8";
    LC_NAME = "ca_ES.UTF-8";
    LC_ADDRESS = "ca_ES.UTF-8";
    LC_TELEPHONE = "ca_ES.UTF-8";
    # Keep messages in English so error messages match what's online.
    LC_MESSAGES = "en_US.UTF-8";
  };
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ca_ES.UTF-8/UTF-8"
    "es_ES.UTF-8/UTF-8"
  ];

  console.keyMap = "es"; # TTY layout
  services.xserver.xkb = {
    layout = "es,us";
    variant = ",";
    options = "grp:alt_shift_toggle,caps:escape"; # alt+shift toggles layouts
  };

  # See `man configuration.nix` before bumping this. Set once at first install,
  # leave alone afterward — it pins stateful-data defaults to that release.
  system.stateVersion = "25.11";
}
