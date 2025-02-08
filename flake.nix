{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # This pins requirements.txt provided by zephyr-nix.pythonEnv.
    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    # Zephyr sdk and toolchain.
    zephyr-nix.url = "github:urob/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    zephyr-nix,
    ...
  }: {
    devShells.x86_64-linux = (
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        zephyr = zephyr-nix.packages.x86_64-linux;
      in {
        default = pkgs.mkShellNoCC {
          packages = [
            zephyr.pythonEnv
            (zephyr.sdk-0_16.override {targets = ["arm-zephyr-eabi"];})

            pkgs.cmake
            pkgs.dtc
            pkgs.ninja

            pkgs.just
            pkgs.yq

            pkgs.gawk
            pkgs.unixtools.column
            pkgs.coreutils
            pkgs.pv
            pkgs.diffutils
            pkgs.findutils
            pkgs.gnugrep
            pkgs.gnused
          ];

          shellHook = ''
            export ZMK_BUILD_DIR=$(pwd)/.build;
            export ZMK_SRC_DIR=$(pwd)/zmk/app;
          '';
        };
      }
    );
  };
}
