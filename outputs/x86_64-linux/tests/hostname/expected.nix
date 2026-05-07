{
  lib,
  outputs,
}:
let
  # nixosConfigurations are named "<host>-<wm>" (e.g. "g14-niri") but
  # networking.hostName is just "<host>" (e.g. "g14"). Strip the "-<wm>"
  # suffix to derive the expected hostName.
  stripWmSuffix = name: builtins.head (lib.strings.splitString "-" name);
  hostsNames = builtins.attrNames outputs.nixosConfigurations;
  expected = lib.genAttrs hostsNames stripWmSuffix;
in
expected
