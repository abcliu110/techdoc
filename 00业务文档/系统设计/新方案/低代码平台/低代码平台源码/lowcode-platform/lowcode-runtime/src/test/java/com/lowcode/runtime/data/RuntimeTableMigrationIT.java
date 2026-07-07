package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
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
          .contains("tenant_id", "app_code", "object_code", "operation", "idempotency_key", "record_lid", "revision");
      assertThat(indexNames(connection, "lc_rt_idempotency"))
          .contains("uk_lc_rt_idempotency_scope");
      assertThat(columnNames(connection, "lc_rt_outbox"))
          .contains("publish_status", "retry_count", "trace_id");
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
}
