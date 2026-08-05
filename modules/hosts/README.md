# WIP DOCS

# Backup restoration
```bash
mount-top-level
cd /mnt/top-level

# Or persistent-restore, to replace on reboot
btrfs subvolume snapshot persistent persistent-preview
# If testing on an existing machine
btrfs subvolume create persistent-preview

# Drop --dry-run if looks sane
# Note that restic will drop common prefixes
restic-local-server restore latest --target persistent-preview --overwrite never --dry-run

reboot

# Boot with persistent-restore boot entry
```

