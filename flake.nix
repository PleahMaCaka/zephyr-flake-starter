{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    zephyr = {
      url = "github:zephyrproject-rtos/zephyr/v4.3.0";
      flake = false;
    };
    zephyr-nix.url = "github:adisbladis/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
  };

  nixConfig = {
    bash-prompt = "zephyr";
    bash-prompt-suffix = " > ";
  };

  outputs = { nixpkgs, flake-utils, zephyr-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zn = zephyr-nix.packages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "zephyr";
          packages = with pkgs; [
            coreutils
            nix
            just
            cmake
            ninja
            python313
            python312Packages.west
            python312Packages.pyelftools
            python312Packages.packaging
            python312Packages.pyyaml
            python312Packages.jsonschema
            tio # to access the shell
            doxygen
          ];
          shellHook = ''
            export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
            export ZEPHYR_SDK_INSTALL_DIR=${zn.sdkFull}
            export PATH=$ZEPHYR_SDK_INSTALL_DIR/arm-zephyr-eabi/bin:$PATH
          '';
        };
      }
    );
}
