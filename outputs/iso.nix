# Old implementation: https://github.com/queze1/nixos-config/blob/4401f760011a703e07107047b5a278e73df2d1d4/modules/outputs/iso.nix
# Previously allowed cross-compilation, removed as it was causing too much lag from nixd and nix flake check
{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    isoModule = {
      # Backdoor the ISO so I can SSH in
      services.openssh.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
      networking.networkmanager.enable = true;

      # Recommended default in 26.11
      boot.zfs.forceImportRoot = false;

      # Recommended in https://gist.github.com/baryluk/70a99b5f26df4671378dd05afef97fce
      isoImage.squashfsCompression = "zstd -Xcompression-level 6 -b 1M";
      nixpkgs.hostPlatform = system;
    };

    # Define an ISO as a NixOS system
    isoSystem =
      inputs.nixpkgs-stable.lib.nixosSystem
      {
        modules = [
          "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          isoModule
        ];
      };

    isoImage = isoSystem.config.system.build.isoImage;
    isoPath = "${isoImage}/${isoSystem.config.image.filePath}";

    # Wrapper around xorriso-dd-target to burn an ISO
    mkIsoBurnerScript = name: let
      innerScript = pkgs.writeShellScript "burn-iso-image-internal" ''
        exec xorriso-dd-target \
          -with_sudo -plug_test -DO_WRITE \
          -image_file ${isoPath} \
          "$@"
      '';
    in
      pkgs.buildFHSEnv {
        inherit name;
        targetPkgs = pkgs:
          with pkgs; [
            libisoburn # contains xorriso-dd-target
            util-linux # contains lsblk
            coreutils # contains basic commands (cat, mkdir, etc.)
            gnugrep
            gnused
            sudo
          ];
        runScript = "${innerScript}";
      };

    # ISO system with a boot test
    # Based on https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/boot.nix
    testIsoSystem =
      inputs.nixpkgs-stable.lib.nixosSystem
      {
        modules = [
          "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs-stable}/nixos/modules/testing/test-instrumentation.nix"
          isoModule
        ];
      };

    testPkgs = testIsoSystem.pkgs;
    testIsoImage = testIsoSystem.config.system.build.isoImage;
    testIsoPath = "${testIsoImage}/${testIsoSystem.config.image.filePath}";
    qemuCommon = testPkgs.callPackage "${inputs.nixpkgs-stable}/nixos/lib/qemu-common.nix" {};
    qemu = qemuCommon.qemuBinary testPkgs.qemu_test;
    isoBootTest = testPkgs.testers.runNixOSTest {
      name = "iso-boot";
      nodes = {};
      testScript = ''
        machine = create_machine("${qemu} -m 2048 -netdev user,id=net0 -device virtio-net-pci,netdev=net0 -cdrom ${testIsoPath} -drive if=pflash,format=raw,unit=0,readonly=on,file=${testPkgs.OVMF.firmware} -drive if=pflash,format=raw,unit=1,readonly=on,file=${testPkgs.OVMF.variables}")
        machine.start()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("${lib.getExe' testPkgs.systemd "systemctl"} is-active sshd.service")
        machine.wait_for_open_port(22)
        machine.succeed("${lib.getExe' testPkgs.gnugrep "grep"} -Fqx '${sshKeys.ableArcherKey}' /root/.ssh/authorized_keys")
        machine.shutdown()
      '';
    };
  in {
    packages =
      lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        iso-system = isoSystem.config.system.build.toplevel;
        iso-image = isoImage;
        burn-iso-image = mkIsoBurnerScript "burn-iso-image";
      }
      // lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        iso-boot-test = isoBootTest;
      };
  };
}
