{
  description = "Alex' nix configuration for NixOS based on Ryan Yin'";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  outputs = inputs: import ./outputs inputs;

  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  #     https://nixos-and-flakes.thiscute.world/nix-store/add-binary-cache-servers
  nixConfig = {
    # substituters will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://cache.numtide.com"
      # "https://nix-gaming.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch by default.
    # Find git commit hash with build status here (3 jobs per day):
    # https://hydra.nixos.org/jobset/nixpkgs/unstable
    # update via: nix flake update nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/<commit-hash>
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Stable channel — fallback for packages that break on unstable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Bleeding edge — for packages not yet in unstable
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # home-manager — managing user-level config, dotfiles, and packages
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # keep home-manager's nixpkgs consistent with ours to avoid duplicate versions
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific NixOS modules — includes ASUS ROG G14 profiles
    # https://github.com/NixOS/nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Catppuccin theme — declarative, consistent theming across all apps
    # https://github.com/catppuccin/nix
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot support via systemd-boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Persist specific paths across tmpfs reboots (impermanence companion)
    preservation = {
      url = "github:nix-community/preservation";
    };

    # Generate ISO/qcow2/Docker/... images from NixOS configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management via age encryption
    agenix = {
      # locked at May 18, 2025
      url = "github:ryantm/agenix/4835b1dc898959d8547a871ef484930675cb47f1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Git hooks to auto-format Nix code before commits
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use Nushell as a Nix build environment shell
    nuenv = {
      url = "github:DeterminateSystems/nuenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Filesystem-based module loading — auto-imports .nix files from folders
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Per-app sandboxing via bubblewrap
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast nix-locate — find which package provides a given binary
    # e.g.: nix-locate bin/ffmpeg
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agent configs (Claude, Aider, etc.) for Nix projects
    llm-agents.url = "github:numtide/llm-agents.nix";

    # -------------- 3D ---------------------

    # Pre-built Blender binaries — much faster than compiling from source
    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -------------- Gaming ---------------------

    # Optimized Wine/Proton, Steam patches, game performance tools
    # Needed for AoE2 via Steam/Proton
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Anime Game Launcher — general gaming utilities
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/main";
      # note: intentionally not following nixpkgs to avoid compatibility issues
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################  Non-flake repositories  #########################################

    # Nushell community scripts — shell completions (git, kubectl, docker, etc.)
    # and utility functions used by utils.nu and the Justfile deployment commands
    nu_scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    ########################  My own repositories  #########################################

    # My private secrets repository — SSH auth via ssh-agent, shallow clone for speed
    # To set up: create a private repo at github.com/<you>/nix-secrets
    mysecrets = {
      url = "git+ssh://git@github.com/alex-pv01/nix-secrets.git?shallow=1";
      flake = false;
    };

    # Wallpapers — replace with your own repo when ready
    # TODO: create github.com/alex-pv01/wallpapers and update this URL
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };
  };
}
