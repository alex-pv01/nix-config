{ pkgs, ... }:
{
  # AMD Ryzen + Radeon Vega iGPU.
  # https://wiki.nixos.org/wiki/AMD_GPU
  # https://wiki.archlinux.org/title/AMDGPU

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # iGPU driver. The dGPU (NVIDIA) is configured separately in hardware-nvidia.nix
  # and used via PRIME offload — see `nvidia-offload <command>`.
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # VA-API for video acceleration on AMD iGPU
      libva
      libvdpau-va-gl
      mesa
      # AMF (AMD's H.264/H.265 encoder for streaming)
      # rocmPackages.clr.icd # OpenCL — uncomment if you do GPU compute on the iGPU
    ];
  };
}
