{
  myvars,
  lib,
}:
let
  username = myvars.username;
  hosts = [
    "g14-niri"
  ];
in
lib.genAttrs hosts (_: "/home/${username}")
