_: {
  # ===========================================================================
  # `pass` (password-store) is intentionally DISABLED in this fork.
  # ===========================================================================
  #
  # Why: `pass` encrypts each entry as a `.gpg` file using a GPG key. The
  # original config hardcoded Ryan's GPG key fingerprints (PASSWORD_STORE_KEY
  # and PASSWORD_STORE_SIGNING_KEY), and the GPG module itself is disabled —
  # see ../gpg/default.nix.
  #
  # ---------------------------------------------------------------------------
  # To RE-ENABLE `pass`:
  # ---------------------------------------------------------------------------
  #
  # 1. First re-enable GPG (see ../gpg/default.nix) and import your key.
  #
  # 2. Find your encryption-subkey and signing-subkey fingerprints:
  #      gpg --list-keys --with-keygrip --keyid-format=long <your-email>
  #
  # 3. Restore the original config:
  #      git show pre-strip-upstream:home/base/tui/password-store/default.nix \
  #        > home/base/tui/password-store/default.nix
  #
  # 4. Replace Ryan's fingerprints in that file with your own:
  #    - PASSWORD_STORE_KEY         → encryption subkey fingerprint
  #    - PASSWORD_STORE_SIGNING_KEY → signing  subkey fingerprint
  #
  # 5. Rebuild: `just switch g14`. Initialize the store with:
  #      pass init <encryption-subkey-fingerprint>
  #
  # ---------------------------------------------------------------------------
}
