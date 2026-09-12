{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.disko;

  # Use a nixos-facter report to guess the main disk
  # 1. Get disks from the report
  # 2. Exclude disks with "usb" in their class list
  # 3. Select the largest disk
  # 4. Get the first /dev/by-id Unix device path
  facterReport = config.hardware.facter.report;
  facterDisks = facterReport.hardware.disk or [];
  eligibleFacterDisks =
    lib.filter (
      disk: !(lib.elem "usb" (disk.class_list or []))
    )
    facterDisks;
  facterDiskSize = disk: let
    sizeResource =
      lib.findFirst (
        resource: (resource.type or null) == "size"
      )
      null (disk.resources or []);
  in
    if sizeResource == null
    then throw "my.disko.useFacterDevice requires every eligible facter disk to have a size resource."
    else if !(sizeResource ? value_1 && sizeResource ? value_2)
    then throw "my.disko.useFacterDevice requires every facter disk size resource to have value_1 and value_2."
    else sizeResource.value_1 * sizeResource.value_2;
  largestFacterDisk =
    if eligibleFacterDisks == []
    then throw "my.disko.useFacterDevice found no eligible disks in the facter report."
    else
      lib.foldl' (
        largest: disk:
          if facterDiskSize disk > facterDiskSize largest
          then disk
          else largest
      ) (builtins.head eligibleFacterDisks) (builtins.tail eligibleFacterDisks);
  detectedFacterDevice =
    if !cfg.useFacterDevice
    then null
    else if facterReport == {}
    then throw "my.disko.useFacterDevice requires a hardware.facter.report."
    else if !(largestFacterDisk ? unix_device_names)
    then throw "my.disko.useFacterDevice requires the selected facter disk to have unix_device_names."
    else let
      byIdPath =
        lib.findFirst (
          name: lib.hasPrefix "/dev/disk/by-id/" name
        )
        null
        largestFacterDisk.unix_device_names;
    in
      if byIdPath == null
      then throw "my.disko.useFacterDevice requires the selected facter disk to have a /dev/disk/by-id/ path."
      else byIdPath;

  device =
    if cfg.useFacterDevice
    then cfg.facterDevice
    else cfg.device;

  # Number of root backups to keep
  rootBackupLimit = 10;
in {
  imports = [inputs.disko.nixosModules.default];

  options.my.disko = {
    profile = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "simpleEfi"
        "btrfsEphemeralRoot"
      ]);
      default = null;
      description = "The disko partitioning profile to use.";
    };
    device = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The device path of the main disk.";
    };
    useFacterDevice = lib.mkEnableOption "guess the device path from the nixos-facter report";
    facterDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true;
      default = detectedFacterDevice;
      description = "Device path detected in the nixos-facter report.";
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.profile == null || device != null;
          message = "No device configured for disko profile";
        }
        {
          assertion = !(cfg.device != null && cfg.useFacterDevice);
          message = "my.disko.device and my.disko.useFacterDevice are incompatible";
        }
      ];
    }

    # Simple filesystem, no swap
    (lib.mkIf (cfg.profile == "simpleEfi" && device != null) {
      disko.devices.disk.main = {
        device = device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [
                  "-L"
                  "nixos"
                ];
              };
            };
          };
        };
      };
    })

    (lib.mkIf (cfg.profile == "btrfsEphemeralRoot" && device != null) {
      fileSystems."/nix".neededForBoot = true;
      fileSystems."/persistent".neededForBoot = true;

      boot.initrd.systemd.services.setup-subvolumes = {
        description = "Set up /root and /persistent";
        wantedBy = ["initrd.target"];
        after = [
          "local-fs-pre.target" # when filesystems are ready for mounting
          "initrd-root-device.target" # when the root filesystem device is avaliable but before it's mounted
          "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device"
        ];
        requires = ["dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device"];
        before = ["sysroot.mount"]; # mounts the root filesystem
        path = with pkgs; [
          btrfs-progs
          coreutils
          util-linux
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          set -euo pipefail

          mkdir -p /btrfs_tmp
          mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp

          mkdir -p /btrfs_tmp/root-backup
          mkdir -p /btrfs_tmp/persistent-backup

          # Back up the old root
          if [[ -e /btrfs_tmp/root ]]; then
              timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
              mv /btrfs_tmp/root "/btrfs_tmp/root-backup/root-$timestamp"
          fi

          if [[ -e /btrfs_tmp/root-restore ]]; then
              # Restore a root if it was placed in root-restore
              mv /btrfs_tmp/root-restore /btrfs_tmp/root
          else
              # Create a new empty root
              btrfs subvolume create /btrfs_tmp/root
          fi

          # Prune old backups over limit
          ls -1 /btrfs_tmp/root-backup | sort -r | tail -n +${toString (rootBackupLimit + 1)} | while read -r old; do
              btrfs subvolume delete -R "/btrfs_tmp/root-backup/$old"
          done

          # Restore a persistent subvolume if it was placed in persistent-restore
          if [[ -e /btrfs_tmp/persistent-restore ]]; then
              timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
              mv /btrfs_tmp/persistent "/btrfs_tmp/persistent-backup/persistent-$timestamp"
              mv /btrfs_tmp/persistent-restore /btrfs_tmp/persistent
          fi

          umount /btrfs_tmp
        '';
      };

      # Shell aliases to mount/unmount the top-level subpartition
      environment.shellAliases = {
        mount-top-level = "sudo mkdir -p /mnt/top-level && sudo mount -o subvolid=5 /dev/disk/by-partlabel/disk-main-root /mnt/top-level";
        umount-top-level = "sudo umount /mnt/top-level";
      };

      specialisation.root-preview.configuration = {lib, ...}: {
        disko.devices.disk.main.content.partitions.root.content.subvolumes = {
          "/root".mountpoint = lib.mkForce "/root-original";
          "/root-preview" = {
            mountOptions = ["noatime"];
            mountpoint = "/";
          };
        };
      };

      specialisation.persistent-preview.configuration = {lib, ...}: {
        disko.devices.disk.main.content.partitions.root.content.subvolumes = {
          "/persistent".mountpoint = lib.mkForce "/persistent-original";
          "/persistent-preview" = {
            mountOptions = ["noatime"];
            mountpoint = "/persistent";
          };
        };
      };

      disko.devices.disk.main = {
        device = device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "nixos"
                ];
                subvolumes = {
                  "/root" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/";
                  };
                  "/persistent" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/persistent";
                  };
                  "/nix" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    })
  ];
}
