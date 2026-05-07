# Archive

This fork of [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) has been stripped of
components irrelevant to a single ASUS Zephyrus G14 laptop. Removed code is **not lost** — git
history preserves it forever. This file indexes what was removed, why, and how to bring it back.

The pristine pre-strip state is at the git tag **`pre-strip-upstream`**:

```bash
# Browse the original tree
git checkout pre-strip-upstream

# See everything that lived in a removed path
git log --all --full-history -- path/to/file

# Restore a specific path (use the SHA from the batch entry below)
git checkout <sha>^ -- path/to/file
```

---

## Batch A — Chinese input methods (fcitx5 + rime + mozc + hangul)

**Removed in:** `4f7737b3` **Original paths:**

- `home/linux/gui/base/fcitx5/` — fcitx5 home-manager module
- `overlays/fcitx5/` — rime-data-flypy package overlay
- `hosts/idols-ai/preservation.nix` — `.config/mozc` persistence line (orphan after fcitx5 removal)

**What it was:** Fcitx5 input-method framework configured with Rime (flypy 小鹤音形) for Chinese,
Mozc for Japanese, and Hangul for Korean. The overlay overrode nixpkgs' `rime-data` with a custom
flypy variant.

**Restore:**

```bash
git checkout 4f7737b3^ -- home/linux/gui/base/fcitx5/ overlays/fcitx5/
# (preservation line edit can be hand-replaced from the diff)
```

---

## Batch B — Chinese-app sandboxes (WeChat, QQ)

**Removed in:** `d30690c6` **Original paths:**

- `hardening/bwraps/` — bubblewrap WeChat sandbox + overlay
- `hardening/nixpaks/qq.nix` — QQ nixpak sandbox
- References pruned from: `hardening/nixpaks/default.nix`, `home/linux/gui/base/misc.nix`,
  `outputs/x86_64-linux/src/idols-ai.nix`

**What it was:** Sandboxed wrappers for WeChat (via bubblewrap) and QQ (via nixpak). Useful as
templates for sandboxing other proprietary GUI apps. The Telegram and Firefox nixpaks remain in
`hardening/nixpaks/` as cleaner examples.

**Restore:**

```bash
git checkout d30690c6^ -- hardening/bwraps/ hardening/nixpaks/qq.nix
# (then hand-restore the lines in nixpaks/default.nix, misc.nix, idols-ai.nix)
```

---

## Batch C — Other-people's hosts

**Removed in:** `3a35a331` **Original paths:**

- `hosts/12kingdoms-shoukei/` (Apple Silicon NixOS laptop, aarch64)
- `hosts/darwin-fern/`, `hosts/darwin-frieren/` (macOS)
- `hosts/idols-akane/` (aarch64 services host)
- `hosts/idols-aquamarine/` (services + monitoring desktop, with extensive Grafana dashboards)
- `hosts/idols-kana/`, `hosts/idols-ruby/` (Ryan's other x86 hosts)
- `outputs/aarch64-darwin/src/{fern,frieren}.nix`
- `outputs/aarch64-linux/src/{12kingdoms-shoukei,idols-akane}.nix`
- `outputs/x86_64-linux/src/{idols-aquamarine,idols-kana,idols-ruby}.nix`
- `outputs/x86_64-linux/nixos-tests/idols-ruby.nix`
- `home/hosts/linux/{12kingdoms-shoukei,idols-aquamarine,idols-kana,idols-ruby}.nix`
- `home/hosts/darwin/{darwin-fern,darwin-frieren}.nix`

Also updated:

- `nixos-installer/flake.nix` — removed shoukei configuration and Apple Silicon inputs
- `outputs/aarch64-linux/tests/{hostname,home-manager}/expected.nix` — dropped shoukei-niri special
  case

**What it was:** Ryan's other machines. `hosts/idols-ai/` is **kept** as fork-source for the
upcoming G14 host. The Grafana/Loki/VictoriaMetrics dashboards under
`hosts/idols-aquamarine/grafana/` are useful reference material for anyone setting up a homelab
observability stack.

**Restore (example for one host):**

```bash
git checkout 3a35a331^ -- hosts/12kingdoms-shoukei outputs/aarch64-linux/src/12kingdoms-shoukei.nix home/hosts/linux/12kingdoms-shoukei.nix
```

---

## Batch D — Homelab Kubernetes (k3s + KubeVirt)

**Removed in:** `cec83ae0` **Original paths:**

- `hosts/k8s/` — entire shared module tree (3 k3s prod masters, 3 prod workers, 3 test masters, 3
  KubeVirt nodes, plus disko-config for KubeVirt)
- `outputs/x86_64-linux/src/k3s-*.nix` (10 files)
- `outputs/x86_64-linux/src/kubevirt-*.nix` (3 files)
- `home/hosts/linux/k3s-prod-1-master-1.nix`, `home/hosts/linux/k3s-test-1-master-1.nix`

Also updated:

- `secrets/nixos.nix` — removed `server.kubernetes.enable` option, the entry from
  `enabledServerSecrets`, and the `(mkIf cfg.server.kubernetes.enable { ... })` block declaring
  `k3s-prod-1-token` and `k3s-test-1-token` age secrets
- `outputs/x86_64-linux/tests/home-manager/{expected,expr}.nix` — dropped `"ruby"` (orphan from
  Batch C) and `"k3s-prod-1-master-1"` from the hosts list

**What it was:** NixOS VMs joining Ryan's homelab Kubernetes cluster (k3s control plane + workers)
and VMs running on top of that cluster via KubeVirt (VMs-as-Kubernetes-pods). Useless without his
Proxmox + MinIO + k3s stack.

**Restore:**

```bash
git checkout cec83ae0^ -- hosts/k8s/ outputs/x86_64-linux/src/k3s-*.nix outputs/x86_64-linux/src/kubevirt-*.nix
# (then hand-restore the secrets/nixos.nix and tests/home-manager/* edits)
```

---

## Batch E — Infrastructure-as-Code (Terraform + MinIO)

**Removed in:** `1c3827c7` **Original paths:**

- `infra/minio/loki/` — MinIO buckets for Loki log aggregation
- `infra/minio/tf-s3-backend/` — Terraform S3 state backend bootstrap

**What it was:** Terraform modules that manage Ryan's MinIO (S3-compatible) buckets, Loki
log-aggregation buckets, and Terraform state backend. Needs a running MinIO server to be useful.

**Restore:**

```bash
git checkout 1c3827c7^ -- infra/
```

---

## Batch F — Cloud provider CLIs

**Removed in:** `9d27518c` **Original paths:**

- `home/base/tui/cloud/default.nix` — packages list
- `home/base/tui/cloud/terraformrc` — Terraform CLI config (linked into `~/.terraformrc`)

**What it was:** CLIs and tooling for AWS, Aliyun (Alibaba Cloud), Google Cloud, and DigitalOcean —
`aws`, `aliyun`, `gcloud`, `doctl`, plus `terraformer`, `eksctl`, `packer`. None are useful without
accounts at the corresponding providers.

**Restore (whole directory, then trim what you don't want):**

```bash
git checkout 9d27518c^ -- home/base/tui/cloud/
```

---

## Batch G — idols-ai (former fork-source) and nixos-installer/

**Removed in:** `30faea65` **Original paths:**

- `hosts/idols-ai/` — Ryan's desktop config: Intel + RTX 4090, impermanence + LUKS + tmpfs root,
  Secure Boot via lanzaboote, second data disk, network mounts. Most of `hosts/g14/` was forked from
  here.
- `outputs/x86_64-linux/src/idols-ai.nix`
- `home/hosts/linux/idols-ai.nix`
- `nixos-installer/` — minimal standalone flake to bootstrap a fresh NixOS install from the live
  ISO. Pointed at `hosts/idols-ai/{disko-fs,hardware-configuration,preservation}.nix` so it stopped
  working once those moved.

Also updated:

- `outputs/x86_64-linux/src/g14.nix` — nixosConfigurations key renamed `g14` → `g14-niri` to match
  the `<host>-<wm>` convention the Justfile `just niri` recipe expects.
- `outputs/x86_64-linux/tests/hostname/expected.nix` — rewritten to derive `networking.hostName` by
  stripping `-<wm>` from each nixosConfigurations attribute name (no special-casing per host).
- `outputs/x86_64-linux/tests/home-manager/{expected,expr}.nix` — `"ai-niri"` → `"g14-niri"`.
- `vars/networking.nix` — `hostsAddr.ai` entry removed (orphan), map left empty with a usage
  example.

**What it was:** `hosts/idols-ai/` is the most complete Ryan-style desktop in the repo: it shows the
full impermanence + LUKS + Secure Boot stack working end-to-end. The `nixos-installer/` flake was
the bootstrap helper for fresh installs from the live ISO. Recover either if you ever want to do a
fresh-install + impermanence migration on the G14 (or any other machine).

**Restore the desktop reference:**

```bash
git checkout 30faea65^ -- hosts/idols-ai outputs/x86_64-linux/src/idols-ai.nix home/hosts/linux/idols-ai.nix
```

**Restore the installer flake:**

```bash
git checkout 30faea65^ -- nixos-installer/
```

---

## Batch H — Colmena fleet deployment + minor cleanup

**Removed in:** `be52000f`  
**Original paths and edits:**

- `outputs/default.nix`:
  - dropped the `colmena = { meta = { ... }; ... }` top-level flake output (Colmena fleet
    deployment metadata)
  - dropped the `debugAttrs = { ... }` top-level output (Ryan-only debug helper)
  - renamed pre-commit hook id `nixfmt-rfc-style` → `nixfmt` (upstream rename; same formatter)
- `outputs/x86_64-linux/default.nix`:
  - dropped the `colmenaMeta = { nodeNixpkgs = ...; nodeSpecialArgs = ...; }` and
    `colmena = lib.attrsets.mergeAttrsList ...` merge lines

**What it was:** [Colmena](https://github.com/zhaofengli/colmena) is a multi-host NixOS
deployment tool — like a native, parallel `nixos-rebuild --target-host`. Useful when you
manage a fleet (Ryan had 12+ machines: k3s nodes, KubeVirt VMs, several desktops).
Pointless for a single laptop.

`debugAttrs` was a helper exposing intermediate values for `nix eval .#debugAttrs`; not
relevant to anyone but the original author. The `nixfmt-rfc-style` rename is purely
cosmetic — same formatter, just the new upstream hook id.

**Restore:**

```bash
git checkout <sha>^ -- outputs/default.nix outputs/x86_64-linux/default.nix
```

You'd also need to install Colmena (`nix-shell -p colmena` or add it to your dev shell)
and define your fleet under the `colmena = { ... }` flake output.

---

## Design choices for the `g14` host (not removed, just deliberately omitted)

These are _not in `hosts/g14/`_ — they were considered, evaluated, and skipped for the initial
install. Documented here so future-you (or anyone else) knows the decision was deliberate, not an
oversight, and where to find templates if you change your mind.

### Storage stack: vanilla ext4 (NOT impermanence + LUKS + btrfs)

**Why:** The G14 was already installed via the standard NixOS installer with ext4 root, no LUKS, no
tmpfs root. Adopting Ryan's impermanence/LUKS/btrfs pattern requires a destructive re-install
(re-partition, re-format, restore data). The user opted to keep the working install instead.

**What's missing vs. idols-ai:**

- `hosts/g14/disko-fs.nix` — would declare GPT + ESP + LUKS2 + btrfs subvolumes
- `hosts/g14/preservation.nix` — would bind-mount /persistent/\* into a tmpfs root
- `disko.nixosModules.default` import + `disko` argument in `hosts/g14/default.nix`
- `modules.secrets.preservation.enable = true` flag in the host registration

**Reference templates** (if you ever migrate the G14 to impermanence):

- `git show pre-strip-upstream:hosts/idols-ai/disko-fs.nix`
- `git show pre-strip-upstream:hosts/idols-ai/preservation.nix`
- The phased migration would require: backup → boot installer ISO → run disko destroy/format/mount
  on the G14's NVMe → `nixos-install --flake .#g14` with the new disko-fs.nix and preservation.nix
  files committed to the host.

### Secure Boot: deferred (NOT lanzaboote)

**Why:** Secure Boot adds a per-rebuild signing step and a fragile key-enrollment process. The plan
was to defer it until the machine is otherwise stable — see Phase 7 in
`~/.claude/plans/i-took-ryan-yin-s-cozy-pebble.md`. Unlike storage layout, this can be added later
without re-installing.

**Reference template:**

- `git show pre-strip-upstream:hosts/idols-ai/secureboot.nix`

### Server-side / cloud secrets: not enabled at the registration

**Why:** The flake's `secrets/nixos.nix` defines an option `modules.secrets.desktop.enable` that,
when set, references age secrets from the user's `nix-secrets` repo. That repo is currently empty,
so enabling this flag would cause activation to fail. Left disabled until the user populates secrets
in Phase 7.

**To enable later:** set `modules.secrets.desktop.enable = true;` in
`outputs/x86_64-linux/src/g14.nix`, after committing the relevant `.age` files to your private
`nix-secrets` repo.
