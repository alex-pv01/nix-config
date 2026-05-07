{ config, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ ../../linux/gui.nix ];

  # Niri compositor + NVIDIA hybrid graphics on the G14.
  modules.desktop.niri.enable = true;
  modules.desktop.nvidia.enable = true;

  # Gaming stack disabled by default; flip to true (here AND in
  # outputs/x86_64-linux/src/g14.nix) when you want Steam/Wine.
  modules.desktop.gaming.enable = false;

  # Per-host Niri output config, symlinked from the repo so `niri msg outputs`
  # changes can be edited live without a full home-manager rebuild.
  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/g14/niri-hardware.kdl";
}
