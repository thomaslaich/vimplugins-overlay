{
  description =
    "A flake that provides overlays for vim plugins in order to use plugins unavailable in nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    lsp-progress = {
      type = "github";
      owner = "linrongbin16";
      repo = "lsp-progress.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, lsp-progress, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        lsp-progress-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "lsp-progress";
          version = "2023-10-13";
          src = lsp-progress;
          meta.homepage = "https://github.com/linrongbin16/lsp-progress.nvim/";
        };

      in { packages = { inherit lsp-progress-nvim; }; }) // {
        overlays.default = final: prev: {
          vimPlugins = prev.vimPlugins.extend (final': prev': {
            inherit (self.packages.${prev.system}) lsp-progress-nvim;
          });
        };
      };
}

