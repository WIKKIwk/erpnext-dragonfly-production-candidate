# Rollback

The enable script writes backups before changing ERPNext:

- `sites/common_site_config.redis-backup.json`
- `Procfile.redis-backup`

Rollback:

```bash
./scripts/dragonfly-full-disable.sh
./scripts/uninstall-user-systemd.sh
```

Then start the bench with its original Redis/Valkey setup.

Before using this in production, take a normal ERPNext backup:

```bash
bench --site <site> backup --with-files
```
