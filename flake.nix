{
  description = "A flake that provides overlays for vim plugins in order to use plugins unavailable in nixpkgs";

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
    startup = {
      type = "github";
      owner = "startup-nvim";
      repo = "startup.nvim";
      flake = false;
    };
    org-bullets = {
      type = "github";
      owner = "nvim-orgmode";
      repo = "org-bullets.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      lsp-progress,
      startup,
      org-bullets,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        lsp-progress-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "lsp-progress";
          version = "2024-05-20";
          src = lsp-progress;
          meta.homepage = "https://github.com/linrongbin16/lsp-progress.nvim/";
        };

        startup-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "startup";
          version = "2023-12-20";
          src = startup;
          meta.homepage = "https://github.com/startup-nvim/startup.nvim";
        };

        org-bullets-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "org-bullets";
          version = "2024-02-21";
          src = org-bullets;
          meta.homepage = "https://github.com/nvim-orgmode/org-bullets.nvim";
        };
      in
      {
        packages = {
          default = lsp-progress-nvim;
          inherit lsp-progress-nvim;
          inherit startup-nvim;
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
