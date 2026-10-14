# Restoring chopper from restic

Rough procedure to rebuild chopper and restore its data.

Assumes:
- the restic repo is at `/external/restic` on `/dev/sdb1` (UUID `a6b4a1b9-1a9b-47d4-b07a-e9fd9d25fe0a`)
- you have the repo password: `agenix -d secrets/restic.age -i ~/.ssh/id_ed25519`

> `disko` wipes the NVMe and the WD Blue. It does **not** touch `/dev/sdb1`
> (`/external`). Check `lsblk -f` first.

## 1. Format and mount

```sh
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko -- \
  --mode destroy,format,mount --flake github:1randomguy/nixconfig#chopper
```

## 2. Install NixOS

```sh
sudo nixos-install --flake github:1randomguy/nixconfig#chopper
```

## 3. Mount the backup repo (anywhere)

The mount point is arbitrary, and it only needs to be mounted when you actually
run the restore — it does **not** need to be mounted during `nixos-install`.

```sh
mkdir -p /mnt/external
mount /dev/sdb1 /mnt/external   # any mount point works
```

## 4. Restore the backup into the target

```sh
export RESTIC_PASSWORD='...'
restic -r /mnt/external/restic restore latest --target /mnt
```

Backed up paths (chopper): `/var/lib/immich`, `/var/lib/immich-media`,
`/var/lib/nextcloud`, `/public`, `/var/lib/samba/private`, `/home/bene/blog`,
`/var/lib/authelia-main`, `/var/lib/tailscale`, `/var/backup/postgresql`, and
the SSH host keys under `/etc/ssh`. Immich's bind-mounted views
(`/var/lib/immich/{upload,library}`) are excluded, so media restores to the
hddpool dataset and host keys land in `/mnt/etc/ssh` (agenix then works on
first boot, no rekey).

## 5. Reboot

```sh
umount -R /mnt/external
reboot
```

## 6. Restore PostgreSQL (after boot)

Only `pg_dump -C` dumps are backed up; the cluster itself is fresh. Load them:

```sh
systemctl stop phpfpm-nextcloud nextcloud-cron immich-server
sudo -u postgres psql -c 'DROP DATABASE IF EXISTS nextcloud;'
sudo -u postgres gunzip -c /var/backup/postgresql/nextcloud.sql.gz | sudo -u postgres psql
sudo -u postgres psql -c 'DROP DATABASE IF EXISTS immich;'
sudo -u postgres gunzip -c /var/backup/postgresql/immich.sql.gz | sudo -u postgres psql
systemctl start phpfpm-nextcloud immich-server
```

## 7. Touch-ups

- `smbpasswd -a bene` if SMB login fails (usually restored via `/var/lib/samba/private`).
- `tailscale status`; re-approve routes if needed (state is restored).
- Nextcloud: `nextcloud-occ upgrade` / `maintenance:repair` if it complains.
- Immich: schema migrations run on start.
