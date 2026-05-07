{ config, lib, ... }:
{
  # The original of this module added:
  #   nix.extraOptions = ''
  #     !include ${config.age.secrets.nix-access-tokens.path}
  #   '';
  #
  # That file is created by agenix when modules.secrets.desktop.enable = true,
  # which references an age-encrypted file inside the (currently empty)
  # nix-secrets repo. With desktop secrets off, config.age.secrets is empty
  # and the !include line errors with `attribute 'nix-access-tokens' missing`.
  #
  # Re-enable when you've:
  #   1. Populated nix-secrets/ with a `nix-access-tokens.age` (e.g.
  #      `access-tokens = github.com=ghp_xxx ...`).
  #   2. Set `modules.secrets.desktop.enable = true` in
  #      outputs/x86_64-linux/src/g14.nix.
  # Then uncomment the block below.
  nix.extraOptions = lib.mkIf (config.age.secrets ? nix-access-tokens) ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
