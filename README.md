<h2 align="center">Alex's NixOS Configuration</h2>

<p align="center">
  <a href="https://nixos.org/">
    <img src="https://img.shields.io/badge/NixOS-25.11-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41" alt="NixOS 25.11"></a>
  <a href="https://github.com/ryan4yin/nix-config">
    <img src="https://img.shields.io/badge/forked%20from-ryan4yin%2Fnix--config-informational.svg?style=for-the-badge&logo=github&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41" alt="forked from ryan4yin/nix-config"></a>
</p>

> **This is a personal fork.** It is set up specifically for my hardware and identity and is
> published for transparency, not as a turn-key template. If you want a polished, well-maintained
> reference config, go to the upstream
> [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## What this repo is

A NixOS configuration for a single machine: a 2021 ASUS Zephyrus G14 (GA401Q\*, AMD Ryzen + NVIDIA
RTX 3050 Mobile hybrid graphics).

It started as a fork of Ryan Yin's [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) and
was trimmed to remove anything irrelevant to a single-laptop setup (homelab Kubernetes,
infrastructure-as-code, multi-host fleets, Chinese input methods, etc.). See
[`ARCHIVE.md`](./ARCHIVE.md) for what was removed and how to recover it from git history.

The G14 was installed via the standard NixOS installer (vanilla ext4 root, no LUKS, no
impermanence). Adopting Ryan's full tmpfs+impermanence+LUKS+Secure-Boot stack would require a
re-install — documented in `ARCHIVE.md` if/when I want to migrate.

## Hosts

| Hostname | Hardware                                              | Window manager         | Status |
| -------- | ----------------------------------------------------- | ---------------------- | ------ |
| `g14`    | ASUS Zephyrus G14 (2021), AMD Ryzen + RTX 3050 Mobile | [Niri][Niri] (Wayland) | Active |

Build/switch:

```bash
sudo nixos-rebuild switch --flake .#g14-niri
# or, from inside the laptop with Justfile:
just niri
```

## Components (inherited from upstream)

|                                                        | NixOS (Wayland)                                            |
| ------------------------------------------------------ | ---------------------------------------------------------- |
| **Window Manager**                                     | [Niri][Niri]                                               |
| **Status bar / launcher / lockscreen / notifications** | [noctalia-shell][noctalia-shell]                           |
| **Display Manager**                                    | [tuigreet][tuigreet]                                       |
| **Color Scheme**                                       | [catppuccin-nix][catppuccin-nix] (mocha + pink)            |
| **Network**                                            | [NetworkManager][NetworkManager]                           |
| **System Monitor**                                     | [Btop][Btop]                                               |
| **File Manager**                                       | [Yazi][Yazi] (TUI), [Thunar][thunar] (GUI)                 |
| **Shell**                                              | [Nushell][Nushell] + [Starship][Starship]                  |
| **Terminal**                                           | [foot][foot] (default), [Kitty][Kitty], [Ghostty][Ghostty] |
| **Editors**                                            | [Helix][Helix] (primary), [Neovim][Neovim], VS Code        |
| **Media**                                              | [mpv][mpv], [imv][imv], [OBS][OBS]                         |
| **Filesystem**                                         | ext4 root (vanilla install — no LUKS, no impermanence)     |

## Layout

```
flake.nix                       inputs (nixpkgs, home-manager, nixos-hardware,
                                lanzaboote, agenix, disko, catppuccin, ...)
outputs/                        haumea auto-discovers host registrations
  └── x86_64-linux/src/g14.nix  registers nixosConfigurations."g14-niri"
lib/nixosSystem.nix             host factory (wraps nixpkgs.lib.nixosSystem)
hosts/g14/                      G14 system config
  ├── default.nix                 hostname, locale (ca_ES), keyboard
  ├── hardware-configuration.nix  ext4 + vfat /boot + swap; AMD modules
  ├── hardware-amd.nix            AMD Ryzen + Radeon Vega iGPU
  ├── hardware-nvidia.nix         RTX 3050 Mobile, PRIME offload, finegrained PM
  ├── hardware-asus.nix           asusd + supergfxd + fwupd
  └── niri-hardware.kdl           per-host Niri output config
modules/                        reusable system modules (desktop, base, ...)
home/                           home-manager (base/, linux/, hosts/g14.nix)
vars/                           username, email, ssh keys, hostnames
secrets/                        agenix integration (uses a private nix-secrets repo)
hardening/                      nixpak sandboxes for Firefox + Telegram
agents/                         LLM coding-agent rules (CLAUDE.md, AGENTS.md)
Justfile                        deploy commands
ARCHIVE.md                      what was removed, why, and how to restore
```

## Setting up a fresh G14

If I ever need to re-install (or someone wants to use this as a reference for a similar laptop):

1. Boot the NixOS installer ISO; partition manually or use `disko` (see the `pre-strip-upstream`
   tag's `nixos-installer/` for the previous bootstrap helper).
2. `sudo nixos-install --no-root-passwd` with a minimal config.
3. After first boot: clone this repo, run `nix flake check`, then
   `sudo nixos-rebuild switch --flake .#g14-niri`.
4. Walk through the validation checklist for laptop hardware: `asusctl profile -p`,
   `supergfxctl -g`, suspend/resume, brightness keys, battery life, etc.

For the original tmpfs-root + LUKS + impermanence layout, see Ryan's
[`hosts/idols-ai/`](https://github.com/ryan4yin/nix-config/tree/main/hosts/idols-ai) or restore the
templates from the `pre-strip-upstream` tag of this fork (see [`ARCHIVE.md`](./ARCHIVE.md)).

## Credits and license

Forked from [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) (MIT, © 2023 Ryan Yin).
The original `LICENSE` is preserved as required. Ryan's
[NixOS & Nix Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book) is an excellent
companion reference.

[Niri]: https://github.com/YaLTeR/niri
[Kitty]: https://github.com/kovidgoyal/kitty
[foot]: https://codeberg.org/dnkl/foot
[Ghostty]: https://github.com/ghostty-org/ghostty
[Nushell]: https://github.com/nushell/nushell
[Starship]: https://github.com/starship/starship
[Btop]: https://github.com/aristocratos/btop
[mpv]: https://mpv.io
[Helix]: https://github.com/helix-editor/helix
[Neovim]: https://github.com/neovim/neovim
[imv]: https://sr.ht/~exec64/imv/
[OBS]: https://obsproject.com
[catppuccin-nix]: https://github.com/catppuccin/nix
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[tuigreet]: https://github.com/apognu/tuigreet
[thunar]: https://gitlab.xfce.org/xfce/thunar
[Yazi]: https://github.com/sxyazi/yazi
[noctalia-shell]: https://github.com/noctalia-dev/noctalia-shell
