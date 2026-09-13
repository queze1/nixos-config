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

# Things you did when setting up iron-hammer
1. Create a simple configuration in `/modules` and `/outputs`.
  - Issue 1: Initially only added to `/modules` , forgot about `/outputs`
  - Issue 2: Remembered that I would have to set the Disko device name. Also realised that home servers had the wrong device name. So decided to fix the device names of the home servers too. To do this, Icreated a Disko option which used a nixos-facter report to set the device name (took a while). Creating this option also required a refacter of Disko.
2. Burn a fresh ISO onto a USB.
  - Issue 1: Realised that I "fixed" the ISO burner script when it wasn't broke, and broke it. Had to find the offending commit and revert it to get the FHS sandbox back.
3. Install using my installer script.
  - Issue 1: Noticed that the target host was trying to access the self-hosted binary cache, which it didn't have access too. Disabled binary cache on the iron-hammer config, didn't work, eventually figured out I had to set the --no-substitute-on-destination flag to not copy over the host's substituters to the target.
4. Login on the new machine.
  - Issue 1: Remembered that I had to set the real password after using the initial password to bootstrap. The comment containing the right command was deleted, so I had to look into an old branch and restore it.
  - Issue 2: After running the command, the password wasn't changed immediately. Fiddled around, a reboot fixed it.
5. Clone the NixOS config repo.
  - Logged into Tailscale using a QR code, which gave me access to Vaultwarden.
  - Created a new SSH key for GitHub (`id_github`), added it.
6. Rebuild
  - Issue 1: Wouldn't commit because no signing key. Had to create a signing key and add to GitHub.
  - Issue 2: Wouldn't rebuild because sops-nix on Home Manager didn't have access to the sops file. Had to create a fresh age key, add it into the secrets repo, push, rekey on laptop, push, then rebuild. (maybe have an option to generate a user sops key too and prompt to add secrets?)
7. Fix a bunch of things
  - Issue 1: CapsLock wasn't mapped to Esc like I was used to. Looked up the problem, added the right code. Had to log in and out.
  - Issue 2: Firefox wasn't being preserved in the right directory (due to not following "don't fix it if it isn't broken"). After rebuilding, the old Mozilla directory was overwritten, so had to login Firefox accounts again.
  - Issue 3: Bitwarden extension wasn't autofilling like normal. IDK why the settings changed, but fixed it.
  - Issue 4: Noctalia default wallpaper broke because I "fixed" it when wasn't broken by using a v5 setting, when I was still on v4. Had to revert the change, log in and out.
8. Add iron-hammer to CI, nixbuild and build configurations

