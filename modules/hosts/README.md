# WIP DOCS

# Backup restoration
```bash
mount-top-level
cd /mnt/top-level

btrfs subvolume create persistent-preview

# Note that restic will drop common prefixes
restic-local-server restore latest --target persistent-preview --dry-run

# Drop --dry-run if looks sane
restic-local-server restore latest --target persistent-preview

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

# Installing NixOS on Oracle Cloud
Image: Canonical Ubuntu 22.04 
```
ssh ubuntu@YOUR_IP
sudo su
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.05 bash -x
```

