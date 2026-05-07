_: {
  # ===========================================================================
  # GPG is intentionally DISABLED in this fork.
  # ===========================================================================
  #
  # Why: GPG (GNU Privacy Guard) is used for encrypted/signed git commits,
  # encrypted secrets via `agenix`, and as the backend for `pass`. The original
  # config sourced a public key from `${mysecrets}/public/...ryan4yin...pub`
  # that no longer exists in this fork's empty nix-secrets repo, so leaving it
  # active would fail evaluation.
  #
  # The `programs.password-store` module in ../password-store/ is also disabled
  # because `pass` depends on GPG.
  #
  # ---------------------------------------------------------------------------
  # To RE-ENABLE GPG once you have a key:
  # ---------------------------------------------------------------------------
  #
  # 1. Generate a key (if you don't already have one):
  #      gpg --quick-generate-key "Alex Pujol <alex-pv01@proton.me>" \
  #        ed25519 cert,sign 0
  #      gpg --quick-add-key <fingerprint> cv25519 encr 2y
  #
  # 2. Export your public key into the nix-secrets repo:
  #      gpg --armor --export <fingerprint> \
  #        > path/to/nix-secrets/public/alex-pv01-gpg-keys.pub
  #      (commit & push to the private repo)
  #
  # 3. Restore the original GPG config (from before the strip):
  #      git show pre-strip-upstream:home/base/tui/gpg/default.nix \
  #        > home/base/tui/gpg/default.nix
  #
  # 4. In that restored file, change the `source = "...ryan4yin..."` line to
  #    point at your exported public key.
  #
  # 5. (Optional) Re-enable password-store: see ../password-store/default.nix.
  #
  # 6. Rebuild: `just switch g14`. Then import:
  #      gpg --import-options keep-ownertrust --import \
  #        path/to/nix-secrets/public/alex-pv01-gpg-keys.pub
  #
  # ---------------------------------------------------------------------------
}
