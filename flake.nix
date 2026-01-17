{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
      ...
    }:
    {
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      overlays = {
        default = pkgs': pkgs: {
          naersk' = pkgs.callPackage naersk { };
          quaigh =
            with pkgs';
            let
              libclang = lib.getLib llvmPackages.clang.cc;
            in
            naersk'.buildPackage {
              src = self;
              env.LIBCLANG_PATH = "${libclang}/lib";
              buildInputs = [
                kissat
                bzip2
                libclang
              ];
            };
        };
      };

      legacyPackages = self.forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            naersk.overlays.default
            self.overlays.default
          ];
        }
      );

      formatter = self.forAllSystems (system: self.legacyPackages."${system}".nixfmt-tree);

      packages = self.forAllSystems (system: {
        inherit (self.legacyPackages."${system}") quaigh;
        default = self.legacyPackages."${system}".quaigh;
      });
    };
}
