#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ $# -eq 2 && -f $1 && ! -e $2 ]] || { echo 'Usage: restore.sh backup.sqlite NEW-destination.sqlite' >&2; exit 2; }
backup=$1
destination=$2
parent=$(dirname -- "$destination")
[[ -d $parent ]] || { echo 'Destination directory must exist' >&2; exit 2; }
name=$(basename -- "$backup")
(cd "$(dirname -- "$backup")" && sha256sum -c "$name.sha256") >&2
[[ $(sqlite3 -readonly "$backup" 'PRAGMA integrity_check;') == ok ]]
tmp=$(mktemp "$parent/.restore-XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
cp -- "$backup" "$tmp"
# A hard link creates the destination atomically and refuses an existing name.
ln -- "$tmp" "$destination"
printf 'Restored verified backup to %s\n' "$destination"
