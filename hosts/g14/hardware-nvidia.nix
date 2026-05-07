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

    # Bus IDs verified on the G14 via `lspci | grep -E "VGA|3D"`:
    #   01:00.0 VGA NVIDIA GA107M [RTX 3050 Mobile]  → PCI:1:0:0
    #   04:00.0 VGA AMD    Cezanne [Radeon Vega]    → PCI:4:0:0
    #
    # mkForce: nixos-hardware's asus-zephyrus-ga401 profile also sets these
    # but its defaults (generic across GA401 variants) may not match a
    # specific 2021 G14. Our values come from lspci on the actual hardware,
    # so we override.
    amdgpuBusId = lib.mkForce "PCI:4:0:0";
    nvidiaBusId = lib.mkForce "PCI:1:0:0";
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
