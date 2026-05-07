{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };

  # Add my custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager/darwin modules.
  genSpecialArgs =
    system:
    inputs
    // {
      inherit mylib myvars;

      # Extra nixpkgs trees as named specialArgs. Hosts/modules can use these
      # to pull a specific package from a different channel without changing
      # the global pkgs. Examples:
      #   pkgs-stable.foo  → from nixos-25.11 (stable)
      #   pkgs-master.foo  → from nixpkgs master (bleeding-edge)
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-master = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-x64 = import nixpkgs {
        system = "x86_64-linux";

        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;

        overlays = import ../overlays args;
      };
    };

  # This is the args for all the haumea modules in this folder.
  args = {
    inherit
      inputs
      lib
      mylib
      myvars
      genSpecialArgs
      ;
  };

  # modules for each supported system.
  # Only x86_64-linux is active right now (the G14). aarch64-linux and
  # aarch64-darwin were dropped along with their hosts; re-add an entry
  # here AND recreate outputs/<arch>/{default.nix, src/, tests/} when you
  # add a host on a new architecture.
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
  };
  darwinSystems = { };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # Add attribute sets into outputs, for debugging
  debugAttrs = {
    inherit
      nixosSystems
      darwinSystems
      allSystems
      allSystemNames
      ;
  };

  # NixOS Hosts
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # Colmena - remote deployment via SSH
  colmena = {
    meta =
      (
        let
          system = "x86_64-linux";
        in
        {
          # colmena's default nixpkgs & specialArgs
          nixpkgs = import nixpkgs { inherit system; };
          specialArgs = genSpecialArgs system;
        }
      )
      // {
        # per-node nixpkgs & specialArgs
        nodeNixpkgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeNixpkgs or { }) nixosSystemValues
        );
        nodeSpecialArgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeSpecialArgs or { }) nixosSystemValues
        );
      };
  }
  // lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);

  # macOS Hosts
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or { }) darwinSystemValues
  );

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # `checks.<system>.<name>` must be a derivation. The previous
  # `eval-tests = allSystems.${system}.evalTests == { }` was a boolean and
  # broke `nix flake check`. Eval-tests are still run because evaluating
  # `nixosConfigurations.g14-niri` forces them via specialArgs anyway —
  # we just don't surface them as a separate `checks` entry.
  checks = forAllSystems (system: {
    pre-commit-check = pre-commit-hooks.lib.${system}.run {
      src = mylib.relativeToRoot ".";
      hooks = {
        nixfmt-rfc-style = {
          enable = true;
          settings.width = 100;
        };
        # Source code spell checker
        typos = {
          enable = true;
          # excludes is the pre-commit-hooks regex list (NOT the same as
          # typos's own extend-exclude in .typos.toml — that one is bypassed
          # when the hook runner passes paths directly on the command line).
          # See the NOTE near the top of .typos.toml.
          excludes = [
            ".+\\.md$" # skip Markdown
          ];
          settings = {
            write = true; # Automatically fix typos
            configPath = ".typos.toml"; # relative to the flake root
            exclude = "rime-data/";
          };
        };
        prettier = {
          enable = true;
          settings = {
            write = true; # Automatically format files
            configPath = ".prettierrc.yaml"; # relative to the flake root
          };
        };
        # deadnix.enable = true; # detect unused variable bindings in `*.nix`
        # statix.enable = true; # lints and suggestions for Nix code(auto suggestions)
      };
    };
  });

  # Development Shells
  devShells = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # fix https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          bashInteractive
          # fix `cc` replaced by clang, which causes nvim-treesitter compilation error
          gcc
          # Nix-related
          nixfmt
          deadnix
          statix
          # spell checker
          typos
          # code formatter
          prettier
        ];
        name = "dots";
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
}
