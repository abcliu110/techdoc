#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly namespace=mysql
readonly deployment=mysql
readonly backup_dir=/tmp/mysql-business-backup
readonly stamp=$(date +%Y%m%d%H%M%S)
readonly output_dir="$backup_dir/$stamp"

target_mysql() {
  kubectl exec "deployment/$deployment" -n "$namespace" -- sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$@"' mysql "$@"
}

target_dump() {
  kubectl exec "deployment/$deployment" -n "$namespace" -- sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$@"' mysqldump "$@"
}

mkdir -p "$output_dir"
databases=$(target_mysql -N -e 'SHOW DATABASES;' | awk '$1 !~ /^(information_schema|performance_schema|mysql|sys)$/')
test -n "$databases"

printf 'timestamp=%s\n' "$stamp" > "$output_dir/MANIFEST.txt"
printf '%s\n' "$databases" | while IFS= read -r database; do
  case "$database" in
    ''|*[!a-zA-Z0-9_]* ) printf 'Unsafe database name: %s\n' "$database" >&2; exit 1 ;;
  esac
  printf 'Backing up %s\n' "$database"
  target_dump --single-transaction --quick --routines --events --triggers \
    --set-gtid-purged=OFF --hex-blob --databases "$database" | gzip -9 > "$output_dir/${database}.sql.gz"
  test -s "$output_dir/${database}.sql.gz"
  sha256sum "$output_dir/${database}.sql.gz" >> "$output_dir/MANIFEST.txt"
done

printf 'databases=%s\n' "$(printf '%s\n' "$databases" | wc -l)" >> "$output_dir/MANIFEST.txt"
printf 'backup_dir=%s\n' "$output_dir" >> "$output_dir/MANIFEST.txt"
printf '%s\n' "$output_dir"
