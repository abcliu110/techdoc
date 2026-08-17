#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly namespace=mysql
readonly deployment=mysql
readonly source_host=192.168.1.119
readonly source_port=3306
readonly source_user=root
readonly destination_databases=(
  a_ams a_biz a_book a_captail a_crm a_mall a_mq a_order a_payment
  a_platform a_pos a_product a_sync a_weachat a_wechat a_wms
  gylregdb nacos xxl_job
)

require_env() {
  local name=$1
  if [[ -z ${!name:-} ]]; then
    printf '%s is required\n' "$name" >&2
    exit 2
  fi
}

mysql_pod() {
  kubectl exec "deployment/$deployment" -n "$namespace" -- "$@"
}

mysql_pod_stdin() {
  kubectl exec -i "deployment/$deployment" -n "$namespace" -- "$@"
}

target_mysql() {
  mysql_pod sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$@"' mysql "$@"
}

quoted_databases() {
  local database
  for database in "${destination_databases[@]}"; do
    printf ' `%s`' "$database"
  done
}

verify_source_databases() {
  local source_databases
  source_databases=$(mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" \
    mysql -h "$source_host" -P "$source_port" -u "$source_user" -N -e 'SHOW DATABASES;')
  local database
  for database in "${destination_databases[@]}"; do
    if ! grep -Fxq -- "$database" <<<"$source_databases"; then
      printf 'Source database is missing: %s\n' "$database" >&2
      exit 1
    fi
  done
}

preflight() {
  require_env SOURCE_MYSQL_PASSWORD
  kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=2m >/dev/null
  verify_source_databases
  printf 'Source databases:\n'
  printf '%s\n' "${destination_databases[@]}"
  printf 'Source data and index size:\n'
  mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" \
    mysql -h "$source_host" -P "$source_port" -u "$source_user" -N -e \
    "SELECT table_schema, ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_mb FROM information_schema.tables WHERE table_schema IN ($(printf "'%s'," "${destination_databases[@]}" | sed 's/,$//')) GROUP BY table_schema ORDER BY table_schema;"
  printf 'Target databases that will be replaced if present:\n'
  target_mysql -N -e 'SHOW DATABASES;' | \
    grep -Fx -f <(printf '%s\n' "${destination_databases[@]}") || true
  df -h /var/lib/rancher/k3s/storage /tmp
}

migrate() {
  require_env SOURCE_MYSQL_PASSWORD
  local stamp dump_file checksum_file database table_list
  stamp=$(date +%Y%m%d%H%M%S)
  dump_file="/tmp/mysql-source-migration-${stamp}.sql"
  checksum_file="${dump_file}.sha256"

  verify_source_databases
  printf 'Creating read-only logical snapshot on the target host...\n'
  mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" \
    mysqldump -h "$source_host" -P "$source_port" -u "$source_user" \
      --single-transaction --quick --routines --events --triggers --set-gtid-purged=OFF \
      --databases "${destination_databases[@]}" > "$dump_file"
  test -s "$dump_file"
  sha256sum "$dump_file" > "$checksum_file"
  printf 'Snapshot created: %s\n' "$dump_file"

  for database in "${destination_databases[@]}"; do
    target_mysql -e "DROP DATABASE IF EXISTS \`$database\`;"
  done

  mysql_pod_stdin sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$dump_file"
  printf 'Imported table counts:\n'
  table_list=$(printf "'%s'," "${destination_databases[@]}")
  table_list=${table_list%,}
  target_mysql -N -e "SELECT table_schema, COUNT(*) FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema IN ($table_list) GROUP BY table_schema ORDER BY table_schema;"
  printf 'Migration completed. Snapshot checksum: %s\n' "$checksum_file"
}

verify() {
  require_env SOURCE_MYSQL_PASSWORD
  local database_list metrics_sql source_metrics target_metrics
  verify_source_databases
  database_list=$(printf "'%s'," "${destination_databases[@]}")
  database_list=${database_list%,}
  metrics_sql="SELECT table_schema, COUNT(*) AS tables, COALESCE(SUM(table_rows), 0) AS estimated_rows, COALESCE(SUM(data_length + index_length), 0) AS bytes FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema IN ($database_list) GROUP BY table_schema ORDER BY table_schema;"
  source_metrics=$(mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" \
    mysql -h "$source_host" -P "$source_port" -u "$source_user" -N -e "$metrics_sql")
  target_metrics=$(target_mysql -N -e "$metrics_sql")
  printf '%s\n' "$source_metrics" > /tmp/mysql-source-metrics.tsv
  printf '%s\n' "$target_metrics" > /tmp/mysql-target-metrics.tsv
  diff -u /tmp/mysql-source-metrics.tsv /tmp/mysql-target-metrics.tsv
  printf 'Migration verification passed for %s databases.\n' "${#destination_databases[@]}"
}

verify_exact_rows() {
  require_env SOURCE_MYSQL_PASSWORD
  local database_list sql source_rows target_rows
  database_list=$(printf "'%s'," "${destination_databases[@]}")
  database_list=${database_list%,}
  sql=$(mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" mysql -h "$source_host" -P "$source_port" -u "$source_user" -N -B -e \
    "SELECT CONCAT(GROUP_CONCAT(CONCAT('SELECT ', QUOTE(table_schema), ',', QUOTE(table_name), ',COUNT(*) FROM \`', REPLACE(table_schema, '\`', '\`\`'), '\`.\`', REPLACE(table_name, '\`', '\`\`'), '\`') ORDER BY table_schema, table_name SEPARATOR ' UNION ALL '), ';') FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema IN ($database_list);")
  source_rows=$(mysql_pod env MYSQL_PWD="$SOURCE_MYSQL_PASSWORD" mysql -h "$source_host" -P "$source_port" -u "$source_user" -N -B -e "$sql")
  target_rows=$(target_mysql -N -B -e "$sql")
  printf '%s\n' "$source_rows" > /tmp/mysql-source-exact-rows.tsv
  printf '%s\n' "$target_rows" > /tmp/mysql-target-exact-rows.tsv
  diff -u /tmp/mysql-source-exact-rows.tsv /tmp/mysql-target-exact-rows.tsv
  printf 'Exact row-count verification passed for %s databases.\n' "${#destination_databases[@]}"
}

restore_snapshot() {
  local dump_file=$1 database
  test -s "$dump_file"
  for database in "${destination_databases[@]}"; do
    target_mysql -e "DROP DATABASE IF EXISTS \`$database\`;"
  done
  mysql_pod_stdin sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$dump_file"
}

restore_business_snapshot() {
  local dump_file=$1 filtered=/tmp/mysql-business.sql
  test -s "$dump_file"
  awk '/^CREATE DATABASE.*`sys`/{skip=1} /^CREATE DATABASE/ && $0 !~ /`sys`/{skip=0} !skip{print}' "$dump_file" > "$filtered"
  test -s "$filtered"
  restore_snapshot "$filtered"
}

repair_sys_schema() {
  local template_pod=mysql-sys-template template_dump=/tmp/mysql8-sys.sql
  kubectl delete pod "$template_pod" -n "$namespace" --ignore-not-found --wait=true >/dev/null
  kubectl run "$template_pod" -n "$namespace" --image=mysql:8.4.7 \
    --restart=Never --env=MYSQL_ALLOW_EMPTY_PASSWORD=yes --command -- mysqld >/dev/null
  trap 'kubectl delete pod "$template_pod" -n "$namespace" --ignore-not-found --wait=true >/dev/null' RETURN
  for _ in $(seq 1 60); do
    if kubectl exec "pod/$template_pod" -n "$namespace" -- mysqladmin ping -uroot --silent >/dev/null 2>&1; then
      break
    fi
    sleep 5
  done
  kubectl exec "pod/$template_pod" -n "$namespace" -- mysqladmin ping -uroot --silent >/dev/null
  kubectl exec "pod/$template_pod" -n "$namespace" -- \
    mysqldump -uroot --routines --events --triggers --skip-lock-tables --add-drop-database --databases sys > "$template_dump"
  test -s "$template_dump"
  target_mysql -e 'DROP DATABASE IF EXISTS `sys`;'
  mysql_pod_stdin sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$template_dump"
}

status() {
  target_mysql -N -e 'SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE FROM information_schema.processlist;'
  target_mysql -N -e 'SELECT table_schema, COUNT(*) FROM information_schema.tables WHERE table_type = "BASE TABLE" AND table_schema IN ("a_ams", "a_biz", "a_book", "a_captail", "a_crm", "a_mall", "a_mq", "a_order", "a_payment", "a_platform", "a_pos", "a_product", "a_sync", "a_weachat", "a_wechat", "a_wms", "gylregdb", "nacos", "sys", "xxl_job") GROUP BY table_schema ORDER BY table_schema;'
}

case ${1:-preflight} in
  preflight) preflight ;;
  migrate) migrate ;;
  verify) verify ;;
  verify-exact-rows) verify_exact_rows ;;
  restore-snapshot) restore_snapshot "${2:?snapshot path is required}" ;;
  restore-business-snapshot) restore_business_snapshot "${2:?snapshot path is required}" ;;
  repair-sys-schema) repair_sys_schema ;;
  status) status ;;
  *) printf 'Usage: %s [preflight|migrate|verify|verify-exact-rows|restore-snapshot|restore-business-snapshot|repair-sys-schema|status]\n' "$0" >&2; exit 2 ;;
esac
