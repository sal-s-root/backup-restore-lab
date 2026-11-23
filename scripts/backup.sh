#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ $# -eq 2 && -f $1 ]] || { echo 'Usage: backup.sh existing.sqlite backup-directory' >&2; exit 2; }
source_db=$1
backup_dir=$2
[[ $backup_dir != *"'"* && $backup_dir != *$'\n'* ]] || { echo 'Unsupported directory characters' >&2; exit 2; }
mkdir -p -- "$backup_dir"
backup_dir=$(cd "$backup_dir" && pwd)
tmp=$(mktemp "$backup_dir/.backup-XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
sqlite3 -readonly "$source_db" '.timeout 5000' ".backup '$tmp'"
[[ $(sqlite3 -readonly "$tmp" 'PRAGMA integrity_check;') == ok ]]
name="backup-$(date -u +%Y%m%dT%H%M%SZ)-$$.sqlite"
ln -- "$tmp" "$backup_dir/$name"
(cd "$backup_dir" && sha256sum "$name" >"$name.sha256")
printf '%s\n' "$backup_dir/$name"
