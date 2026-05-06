{
  lib,
  outputs,
}:
let
  hostsNames = builtins.attrNames outputs.nixosConfigurations;
  # hostName matches the nixosConfigurations attribute name for all current hosts
  expected = lib.genAttrs hostsNames (name: name);
in
expected
