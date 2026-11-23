#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
sqlite3 "$work/source.sqlite" <fixture.sql
backup=$(bash scripts/backup.sh "$work/source.sqlite" "$work/backups")
bash scripts/restore.sh "$backup" "$work/restored.sqlite"
[[ $(sqlite3 -readonly "$work/restored.sqlite" 'SELECT count(*) FROM records;') -eq 3 ]]
[[ $(sqlite3 -readonly "$work/restored.sqlite" 'PRAGMA integrity_check;') == ok ]]
if bash scripts/restore.sh "$backup" "$work/restored.sqlite" >/dev/null 2>&1; then
  echo 'Expected refusal to overwrite existing destination' >&2; exit 1
fi
printf 'corruption' >>"$backup"
if bash scripts/restore.sh "$backup" "$work/corrupt-restore.sqlite" >/dev/null 2>&1; then
  echo 'Expected checksum failure' >&2; exit 1
fi
[[ ! -e $work/corrupt-restore.sqlite ]]
echo 'Restore drill passed: content, integrity, overwrite refusal, corruption rejection.'
