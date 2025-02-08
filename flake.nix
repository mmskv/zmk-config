{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zmk-nix,
  }: let
  in {
    packages.x86_64-linux = rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.x86_64-linux.buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig"];

        board = "nice_nano_v2";
        shield = "hillside46_%PART%";
        #shield = "settings_reset";

        zephyrDepsHash = "sha256-VlNiXOv+PIk47gFxnpWM0tJQ/Kqb6NW0L6hgCFonCts=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.x86_64-linux.flash.override {inherit firmware;};
    };
  };
}
