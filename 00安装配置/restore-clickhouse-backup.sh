#!/usr/bin/env bash
set -euo pipefail
trap 'echo "RESTORE_FAILED line=$LINENO" >&2' ERR

backup_dir=${1:?usage: restore-clickhouse-backup.sh <backup-dir>}
namespace=lgy
secret=clickhouse-secrets
service=http://127.0.0.1:30793/

for required in bi reportcenter manifest.tsv; do
  test -e "$backup_dir/$required"
done

password=$(kubectl -n "$namespace" get secret "$secret" -o yaml \
  | grep CLICKHOUSE_PASSWORD \
  | cut -d: -f2 \
  | xargs \
  | base64 -d)

query() {
  curl --fail --silent --show-error --user "default:$password" "$service" --data-binary @-
}

for database in bi reportcenter; do
  printf 'CREATE DATABASE IF NOT EXISTS %s' "$database" | query >/dev/null
  table_count=$(printf 'SHOW TABLES FROM %s' "$database" | query | wc -l)
  if test "$table_count" -ne 0; then
    echo "target database is not empty: $database" >&2
    exit 1
  fi
done

restored=0
while IFS=$'\t' read -r database table rows bytes file; do
  case "$database" in
    database*) continue ;;
  esac
  file=${file%$'\r'}
  input="$backup_dir/$file"
  test -f "$input"
  awk '/^INSERT INTO table/{exit} {print}' "$input" \
    | sed '1s/CREATE TABLE /CREATE TABLE IF NOT EXISTS /' \
    | query >/dev/null
  if grep -q '^INSERT INTO table' "$input"; then
    sed -n '/^INSERT INTO table/,$p' "$input" \
      | sed "s/INSERT INTO table /INSERT INTO $database.$table /" \
      | query >/dev/null
  fi
  actual=$(printf 'SELECT count() FROM %s.%s' "$database" "$table" | query)
  if test "$actual" != "$rows"; then
    echo "row count mismatch: $database.$table expected=$rows actual=$actual" >&2
    exit 1
  fi
  restored=$((restored + 1))
done < "$backup_dir/manifest.tsv"

echo "RESTORED tables=$restored"
