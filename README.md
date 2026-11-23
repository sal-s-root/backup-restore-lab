# Backup and restore lab

A Bash/SQLite exercise that verifies recovery instead of assuming a copied file
is a usable backup. It uses SQLite's online backup interface, a SHA-256 manifest,
structural integrity checks, restrictive file permissions, and an atomic restore
that refuses to replace an existing destination.

```sh
make test
# Own lab data only:
bash scripts/backup.sh /path/to/source.sqlite /path/to/backups
bash scripts/restore.sh /path/to/backup.sqlite /path/to/NEW-restored.sqlite
```

The automated drill creates a temporary database, backs it up, restores it,
checks all three records and database integrity, refuses an overwrite, then
corrupts the backup and confirms recovery is rejected. Temporary data is removed.

## Operational decisions

Checksums detect accidental changes, not malicious replacement of both backup
and manifest. Production backup designs also need authenticated encryption,
off-host or immutable copies, retention policy, key management, monitoring, and
periodic restore drills. No retention deletion is automated here. SQLite backups
are not a general PostgreSQL, MySQL, filesystem, or multi-service backup strategy.

Record measured restore duration and the observation window when evaluating an
RTO/RPO; this lab makes no production recovery guarantee.
