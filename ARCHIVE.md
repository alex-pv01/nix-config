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

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `home/linux/gui/base/fcitx5/`

**What it was:** Fcitx5 input-method framework configured with Rime (flypy 小鹤音形)
for Chinese, Mozc for Japanese, and Hangul for Korean. Useful only if you need CJK
input — irrelevant for a Catalan/Spanish setup.

**Restore:**
```bash
git checkout <sha>^ -- home/linux/gui/base/fcitx5/
```

---

## Batch B — Chinese-app sandboxes (WeChat, QQ)

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `hardening/bwraps/` (WeChat bubblewrap sandbox)
- `hardening/nixpaks/qq.nix` (QQ nixpak sandbox)

**What it was:** Sandboxed wrappers for WeChat and QQ — Chinese instant-messaging
apps. Useful as templates for sandboxing other proprietary GUI apps; otherwise dead
weight.

**Restore:**
```bash
git checkout <sha>^ -- hardening/bwraps/ hardening/nixpaks/qq.nix
```

---

## Batch C — Other-people's hosts

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `hosts/idols-{kana,ruby,akane,aquamarine}/`
- `hosts/12kingdoms-shoukei/`
- `hosts/darwin-*/` (any macOS hosts)
- Their corresponding `outputs/<system>/src/*.nix` registrations

**What it was:** Ryan's other machines — desktop variants, an M2 MacBook running
NixOS aarch64, and macOS hosts. `hosts/idols-ai/` is intentionally **kept** as the
fork-source for the G14 host configuration.

**Restore (example for one host):**
```bash
git checkout <sha>^ -- hosts/idols-kana outputs/x86_64-linux/src/idols-kana.nix
```

---

## Batch D — Homelab Kubernetes (k3s + KubeVirt)

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `hosts/k3s*/`
- `hosts/kubevirt*/`
- `outputs/x86_64-linux/src/k3s-*.nix`
- `outputs/x86_64-linux/src/kubevirt-*.nix`

**What it was:** NixOS VMs that join Ryan's homelab Kubernetes cluster (k3s control
plane + workers) and VMs running on top of that cluster via KubeVirt (VMs-as-pods).
Useless without his Proxmox + MinIO + k3s stack.

**Restore:**
```bash
git checkout <sha>^ -- hosts/k3s* hosts/kubevirt* outputs/x86_64-linux/src/k3s-*.nix outputs/x86_64-linux/src/kubevirt-*.nix
```

---

## Batch E — Infrastructure-as-Code (Terraform + MinIO)

**Removed in:** _(SHA filled in after commit)_
**Original paths:**
- `infra/`

**What it was:** Terraform modules that manage Ryan's MinIO (S3-compatible) buckets,
Loki log-aggregation buckets, and Terraform state backend. Needs a running MinIO
server to be useful.

**Restore:**
```bash
git checkout <sha>^ -- infra/
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
