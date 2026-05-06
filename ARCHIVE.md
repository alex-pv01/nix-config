# Archive

This fork of [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) has been
stripped of components irrelevant to a single ASUS Zephyrus G14 laptop. Removed code
is **not lost** — git history preserves it forever. This file indexes what was removed,
why, and how to bring it back.

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

**Removed in:** `4f7737b3`
**Original paths:**
- `home/linux/gui/base/fcitx5/` — fcitx5 home-manager module
- `overlays/fcitx5/` — rime-data-flypy package overlay
- `hosts/idols-ai/preservation.nix` — `.config/mozc` persistence line (orphan after fcitx5 removal)

**What it was:** Fcitx5 input-method framework configured with Rime (flypy 小鹤音形)
for Chinese, Mozc for Japanese, and Hangul for Korean. The overlay overrode
nixpkgs' `rime-data` with a custom flypy variant.

**Restore:**
```bash
git checkout 4f7737b3^ -- home/linux/gui/base/fcitx5/ overlays/fcitx5/
# (preservation line edit can be hand-replaced from the diff)
```

---

## Batch B — Chinese-app sandboxes (WeChat, QQ)

**Removed in:** `d30690c6`
**Original paths:**
- `hardening/bwraps/` — bubblewrap WeChat sandbox + overlay
- `hardening/nixpaks/qq.nix` — QQ nixpak sandbox
- References pruned from: `hardening/nixpaks/default.nix`, `home/linux/gui/base/misc.nix`, `outputs/x86_64-linux/src/idols-ai.nix`

**What it was:** Sandboxed wrappers for WeChat (via bubblewrap) and QQ (via nixpak).
Useful as templates for sandboxing other proprietary GUI apps. The Telegram and
Firefox nixpaks remain in `hardening/nixpaks/` as cleaner examples.

**Restore:**
```bash
git checkout d30690c6^ -- hardening/bwraps/ hardening/nixpaks/qq.nix
# (then hand-restore the lines in nixpaks/default.nix, misc.nix, idols-ai.nix)
```

---

## Batch C — Other-people's hosts

**Removed in:** `3a35a331`
**Original paths:**
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
- `outputs/aarch64-linux/tests/{hostname,home-manager}/expected.nix` — dropped shoukei-niri special case

**What it was:** Ryan's other machines. `hosts/idols-ai/` is **kept** as fork-source
for the upcoming G14 host. The Grafana/Loki/VictoriaMetrics dashboards under
`hosts/idols-aquamarine/grafana/` are useful reference material for anyone setting
up a homelab observability stack.

**Restore (example for one host):**
```bash
git checkout 3a35a331^ -- hosts/12kingdoms-shoukei outputs/aarch64-linux/src/12kingdoms-shoukei.nix home/hosts/linux/12kingdoms-shoukei.nix
```

---

## Batch D — Homelab Kubernetes (k3s + KubeVirt)

**Removed in:** `cec83ae0`
**Original paths:**
- `hosts/k8s/` — entire shared module tree (3 k3s prod masters, 3 prod workers, 3 test masters, 3 KubeVirt nodes, plus disko-config for KubeVirt)
- `outputs/x86_64-linux/src/k3s-*.nix` (10 files)
- `outputs/x86_64-linux/src/kubevirt-*.nix` (3 files)
- `home/hosts/linux/k3s-prod-1-master-1.nix`, `home/hosts/linux/k3s-test-1-master-1.nix`

Also updated:
- `secrets/nixos.nix` — removed `server.kubernetes.enable` option, the entry from `enabledServerSecrets`, and the `(mkIf cfg.server.kubernetes.enable { ... })` block declaring `k3s-prod-1-token` and `k3s-test-1-token` age secrets
- `outputs/x86_64-linux/tests/home-manager/{expected,expr}.nix` — dropped `"ruby"` (orphan from Batch C) and `"k3s-prod-1-master-1"` from the hosts list

**What it was:** NixOS VMs joining Ryan's homelab Kubernetes cluster (k3s control
plane + workers) and VMs running on top of that cluster via KubeVirt
(VMs-as-Kubernetes-pods). Useless without his Proxmox + MinIO + k3s stack.

**Restore:**
```bash
git checkout cec83ae0^ -- hosts/k8s/ outputs/x86_64-linux/src/k3s-*.nix outputs/x86_64-linux/src/kubevirt-*.nix
# (then hand-restore the secrets/nixos.nix and tests/home-manager/* edits)
```

---

## Batch E — Infrastructure-as-Code (Terraform + MinIO)

**Removed in:** `1c3827c7`
**Original paths:**
- `infra/minio/loki/` — MinIO buckets for Loki log aggregation
- `infra/minio/tf-s3-backend/` — Terraform S3 state backend bootstrap

**What it was:** Terraform modules that manage Ryan's MinIO (S3-compatible) buckets,
Loki log-aggregation buckets, and Terraform state backend. Needs a running MinIO
server to be useful.

**Restore:**
```bash
git checkout 1c3827c7^ -- infra/
```

---

## Batch F — Cloud provider CLIs

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `home/base/tui/cloud/`

**What it was:** CLIs and tooling for AWS, Aliyun (Alibaba Cloud), Google Cloud, and
DigitalOcean — `aws`, `aliyun`, `gcloud`, `doctl`, plus `terraformer`, `eksctl`,
`packer`. None are useful without accounts at the corresponding providers.

**Restore (single provider):**
```bash
# Restore the whole directory, then trim what you don't want
git checkout <sha>^ -- home/base/tui/cloud/
```
