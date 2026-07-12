package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@EnabledIfSystemProperty(named = "lowcode.it", matches = "true")
@Testcontainers(disabledWithoutDocker = true)
class RuntimeTableMigrationIT {

  @Container
  private static final MySQLContainer<?> MYSQL =
      new MySQLContainer<>("mysql:8.0.37")
          .withDatabaseName("lowcode")
          .withUsername("lowcode")
          .withPassword("lowcode");

  @Test
  void flywayMigration_shouldCreateRuntimeTablesOnRealMySql() throws SQLException {
    Flyway.configure()
        .dataSource(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword())
        .locations("classpath:db/migration")
        .load()
        .migrate();

    try (Connection connection =
        DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword())) {
      assertThat(tableNames(connection))
          .contains("lc_rt_idempotency", "lc_rt_audit_log", "lc_rt_outbox", "lc_rt_transition_log");
      assertThat(columnNames(connection, "lc_rt_idempotency"))
          .contains("tenant_id", "workspace_id", "app_code", "object_code", "operation", "idempotency_key", "record_lid", "revision");
      assertThat(nullable(connection, "lc_rt_idempotency", "workspace_id")).isEqualTo("NO");
      assertThat(indexNames(connection, "lc_rt_idempotency"))
          .contains("uk_lc_rt_idempotency_scope");
      assertThat(indexColumns(connection, "lc_rt_idempotency", "uk_lc_rt_idempotency_scope"))
          .containsExactly("tenant_id", "workspace_id", "app_code", "object_code", "operation", "idempotency_key");
      assertThat(columnNames(connection, "lc_rt_outbox"))
          .contains("publish_status", "retry_count", "trace_id");
    }
  }

  @Test
  void flywayMigration_shouldUpgradeLegacyIdempotencyScopeWithWorkspace() throws SQLException {
    String database = "lowcode_upgrade";
    try (Connection admin =
        DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword())) {
      admin.createStatement().execute("drop database if exists " + database);
      admin.createStatement().execute("create database " + database);
    }

    String jdbcUrl = MYSQL.getJdbcUrl().replace("/lowcode", "/" + database);
    try (Connection connection = DriverManager.getConnection(jdbcUrl, MYSQL.getUsername(), MYSQL.getPassword())) {
      connection.createStatement().execute("""
          create table lc_rt_idempotency (
            id bigint not null,
            tenant_id bigint not null,
            app_code varchar(64) not null,
            object_code varchar(64) not null,
            operation varchar(32) not null,
            idempotency_key varchar(128) not null,
            record_lid varchar(26) not null,
            from_state varchar(64) not null default '',
            to_state varchar(64) not null default '',
            revision bigint not null,
            trace_id varchar(64) not null,
            create_time datetime(3) not null default current_timestamp(3),
            primary key (id),
            unique key uk_lc_rt_idempotency_scope (tenant_id, app_code, object_code, operation, idempotency_key)
          )
          """);
      connection.createStatement().execute("""
          insert into lc_rt_idempotency
            (id, tenant_id, app_code, object_code, operation, idempotency_key, record_lid, from_state, to_state, revision, trace_id)
          values
            (1, 9, 'sales', 'order', 'create', 'idem-1', 'rec-1', '', '', 1, 'trace-1')
          """);
    }

    Flyway.configure()
        .dataSource(jdbcUrl, MYSQL.getUsername(), MYSQL.getPassword())
        .locations("classpath:db/migration")
        .baselineVersion("202607060001")
        .baselineOnMigrate(true)
        .load()
        .migrate();

    try (Connection connection = DriverManager.getConnection(jdbcUrl, MYSQL.getUsername(), MYSQL.getPassword())) {
      assertThat(columnNames(connection, "lc_rt_idempotency")).contains("workspace_id");
      assertThat(nullable(connection, "lc_rt_idempotency", "workspace_id")).isEqualTo("NO");
      assertThat(indexColumns(connection, "lc_rt_idempotency", "uk_lc_rt_idempotency_scope"))
          .containsExactly("tenant_id", "workspace_id", "app_code", "object_code", "operation", "idempotency_key");
      assertThat(workspaceIds(connection, "lc_rt_idempotency")).containsExactly(0L);
    }
  }

  private static Set<String> tableNames(Connection connection) throws SQLException {
    Set<String> tables = new HashSet<>();
    try (ResultSet resultSet = connection.getMetaData().getTables(null, null, "lc_rt_%", null)) {
      while (resultSet.next()) {
        tables.add(resultSet.getString("TABLE_NAME"));
      }
    }
    return tables;
  }

  private static Set<String> columnNames(Connection connection, String tableName) throws SQLException {
    Set<String> columns = new HashSet<>();
    try (ResultSet resultSet = connection.getMetaData().getColumns(null, null, tableName, "%")) {
      while (resultSet.next()) {
        columns.add(resultSet.getString("COLUMN_NAME"));
      }
    }
    return columns;
  }

  private static Set<String> indexNames(Connection connection, String tableName) throws SQLException {
    Set<String> indexes = new HashSet<>();
    try (ResultSet resultSet = connection.getMetaData().getIndexInfo(null, null, tableName, false, false)) {
      while (resultSet.next()) {
        indexes.add(resultSet.getString("INDEX_NAME"));
      }
    }
    return indexes;
  }

  private static String nullable(Connection connection, String tableName, String columnName) throws SQLException {
    try (ResultSet resultSet = connection.getMetaData().getColumns(null, null, tableName, columnName)) {
      assertThat(resultSet.next()).as(tableName + "." + columnName + " exists").isTrue();
      return resultSet.getString("IS_NULLABLE");
    }
  }

  private static List<String> indexColumns(Connection connection, String tableName, String indexName) throws SQLException {
    List<String> columns = new ArrayList<>();
    try (ResultSet resultSet = connection.getMetaData().getIndexInfo(null, null, tableName, false, false)) {
      while (resultSet.next()) {
        if (indexName.equals(resultSet.getString("INDEX_NAME"))) {
          columns.add(resultSet.getString("COLUMN_NAME"));
        }
      }
    }
    return columns;
  }

  private static List<Long> workspaceIds(Connection connection, String tableName) throws SQLException {
    List<Long> workspaceIds = new ArrayList<>();
    try (ResultSet resultSet = connection.createStatement()
        .executeQuery("select workspace_id from " + tableName + " order by id")) {
      while (resultSet.next()) {
        workspaceIds.add(resultSet.getLong("workspace_id"));
      }
    }
    return workspaceIds;
  }
}
