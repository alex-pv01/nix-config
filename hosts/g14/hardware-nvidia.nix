{
  config,
  lib,
  ...
}:
{
  # =============================================================================
  # NVIDIA dGPU on the G14 — hybrid graphics with PRIME offload.
  # https://wiki.nixos.org/wiki/NVIDIA
  # =============================================================================

  hardware.nvidia.prime = {
    # By default the dGPU sleeps and the iGPU handles everything. Apps that
    # need the dGPU run via `nvidia-offload <cmd>` (or by setting the
    # __NV_PRIME_RENDER_OFFLOAD=1 env var).
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    # ============================================================
    # TODO: replace these placeholders before first install.
    # ============================================================
    # On the G14, run `lspci | grep -E "VGA|3D"` and translate the bus address
    # to the PCI:domain@bus:device:function format expected here.
    # Example output and translation:
    #   05:00.0 VGA compatible controller: AMD ...      → "PCI:5@0:0:0"
    #   01:00.0 3D controller: NVIDIA ...               → "PCI:1@0:0:0"
    amdgpuBusId = "PCI:5@0:0:0"; # PLACEHOLDER — verify on the G14
    nvidiaBusId = "PCI:1@0:0:0"; # PLACEHOLDER — verify on the G14
  };

  boot.kernelParams = [
    # KMS is needed for Wayland compositors (Niri).
    "nvidia-drm.fbdev=1"
  ];

  hardware.nvidia = {
    # Open-source kernel modules — recommended for Turing+ (RTX 20-series and
    # newer). The 3050/3060/3070/3080 in the G14 are Ampere → all supported.
    open = true;
    nvidiaSettings = true;

    # Production driver track (more stable than `latest`/`beta`).
    package = config.boot.kernelPackages.nvidiaPackages.production;

    modesetting.enable = true;
    powerManagement = {
      enable = true; # save dGPU power when idle / on suspend
      # finegrained: with PRIME offload, fully power down the dGPU when no
      # offloaded process is running. Critical for battery life and for
      # reliable resume from suspend on hybrid Ampere laptops.
      # https://download.nvidia.com/XFree86/Linux-x86_64/535.86.05/README/dynamicpowermanagement.html
      finegrained = true;
    };
    # On Ampere mobile parts, dynamicBoost shifts the wattage budget between
    # CPU and GPU under load. Wired up by the asus-zephyrus-ga401 hardware
    # profile; left as mkDefault so that profile can override if needed.
    dynamicBoost.enable = lib.mkDefault true;
  };

  # Run CUDA workloads in containers (podman/docker).
  hardware.nvidia-container-toolkit.enable = true;
}
