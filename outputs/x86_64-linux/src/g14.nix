{
  # NOTE: arguments not used in this file CAN NOT be removed!
  # haumea passes arguments lazily; mylib.nixosSystem and friends require them.
  inputs,
  lib,
  myvars,
  mylib,
  system,
  genSpecialArgs,
  niri,
  ...
}@args:
let
  name = "g14";
  base-modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # Common cross-host modules
        "secrets/nixos.nix"
        "modules/nixos/desktop.nix"

        # This host
        "hosts/${name}"

        # NixOS hardening — keep nixpaks (Firefox + Telegram sandboxes); skip
        # the WIP profiles/ tree and the bwraps/ tree we archived.
        "hardening/nixpaks"
      ])
      ++ [
        {
          modules.desktop.fonts.enable = true;
          modules.desktop.wayland.enable = true;

          # Disabled until set up:
          # - secrets.desktop.enable references age-encrypted files in
          #   nix-secrets that don't exist yet (Phase 7).
          # - secrets.preservation.enable controls a tmpfs/impermanence-only
          #   code path; the G14 was installed with conventional ext4 and
          #   doesn't use that pattern. See ARCHIVE.md.
          modules.secrets.desktop.enable = false;
          modules.secrets.preservation.enable = false;

          # Gaming setup (Steam, Wine, etc.) — enable when you want it (Phase 7).
          modules.desktop.gaming.enable = false;
        }
      ];

    home-modules = map mylib.relativeToRoot [
      "home/hosts/linux/${name}.nix"
    ];
  };

  modules-niri = {
    nixos-modules = [
      { programs.niri.enable = true; }
    ]
    ++ base-modules.nixos-modules;
    home-modules = base-modules.home-modules;
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.nixosSystem (modules-niri // args);
  };

  # Optional: build an installer ISO for this host with `nix build .#g14`.
  packages = {
    "${name}" = inputs.self.nixosConfigurations."${name}".config.formats.iso;
  };
}
