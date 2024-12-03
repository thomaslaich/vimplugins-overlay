{
  description = "A flake that provides overlays for vim plugins in order to use plugins unavailable in nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    org-bullets = {
      type = "github";
      owner = "nvim-orgmode";
      repo = "org-bullets.nvim";
      flake = false;
    };
    kubectl = {
      type = "github";
      owner = "Ramilito";
      repo = "kubectl.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      org-bullets,
      kubectl,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        org-bullets-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "org-bullets";
          version = "2024-09-12";
          src = org-bullets;
          meta.homepage = "https://github.com/nvim-orgmode/org-bullets.nvim";
        };

        kubectl-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "kubectl";
          version = "2024-12-01";
          src = kubectl;
          meta.homepage = "https://github.com/Ramilito/kubectl.nvim";
        };
      in
      {
        packages = {
          default = kubectl-nvim;
          inherit kubectl-nvim;
          inherit org-bullets-nvim;
        };
      }
    )
    // {
      overlays.default = final: prev: {
        vimPlugins = prev.vimPlugins.extend (
          final': prev': {
            inherit (self.packages.${prev.system}) lsp-progress-nvim startup-nvim org-bullets-nvim;
          }
        );
      };
    };
}
