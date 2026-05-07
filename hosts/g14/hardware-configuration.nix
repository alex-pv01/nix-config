# =============================================================================
# REPLACE THIS FILE with the contents of /etc/nixos/hardware-configuration.nix
# from your live G14 NixOS install.
# =============================================================================
#
# How to do it:
#
#   1. On the G14:
#        cat /etc/nixos/hardware-configuration.nix
#
#   2. Copy the entire file contents.
#
#   3. Paste here, replacing this whole file.
#
#   4. Append (do not duplicate) any of the kernel-param recommendations
#      below if your installer's generated file doesn't already include them:
#
#        boot.kernelParams = [
#          # AMD: prefer the modern P-state driver (better perf-per-watt
#          # on Ryzen 5000-series). Keep only if not already set.
#          "amd_pstate=active"
#        ];
#
# Why we keep this here, even though it's "auto-generated": the flake needs
# the file at evaluation time to know your filesystem UUIDs, kernel modules,
# bootloader config, etc. Putting it under hosts/g14/ makes the host
# self-contained and version-controllable.
#
# Until you replace this stub, evaluation of nixosConfigurations.g14 will
# fail (no fileSystems."/" defined).
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ----- Placeholder values follow; the installer's generated file knows the
  # ----- real ones (UUIDs, kernel modules, etc.). Replace this whole block.

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-amd" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # The installer-generated file will add e.g.:
  #   fileSystems."/"     = { device = "/dev/disk/by-uuid/..."; fsType = "ext4"; };
  #   fileSystems."/boot" = { device = "/dev/disk/by-uuid/..."; fsType = "vfat"; };
  #   swapDevices         = [ { device = "/dev/disk/by-uuid/..."; } ];
  # WITHOUT THESE the system has no root and won't build.
}
