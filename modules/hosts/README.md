# WIP DOCS

# Backup restoration
```bash
mount-top-level
cd /mnt/top-level

btrfs subvolume create persistent-preview

# Drop --dry-run if looks sane
# Note that restic will drop common prefixes
restic-local-server restore latest --target persistent-preview --dry-run

# Overwrite old host keys
cp -p /persistent/etc/ssh/ssh_host_rsa_key persistent-preview/etc/ssh/ssh_host_rsa_key
cp -p /persistent/etc/ssh/ssh_host_ed25519_key persistent-preview/etc/ssh/ssh_host_ed25519_key

reboot

# Boot with persistent-preview boot entry

# If looks okay, restore backup
mount-top-level
cd /mnt/top-level
mv persistent-preview persistent-restore

# Moves /persistent into /persistent-backup and /persistent-restore into /persistent on boot
reboot
```

