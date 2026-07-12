package com.lowcode.metamodel.dao.migration;

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
class MetaTableMigrationIT {

  @Container
  private static final MySQLContainer<?> MYSQL =
      new MySQLContainer<>("mysql:8.0.37")
          .withDatabaseName("lowcode")
          .withUsername("lowcode")
          .withPassword("lowcode");

  @Test
  void flywayMigration_shouldCreateM0TablesOnRealMySql() throws SQLException {
    Flyway.configure()
        .dataSource(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword())
        .locations("classpath:db/migration")
        .load()
        .migrate();

    try (Connection connection =
        DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword())) {
      assertThat(tableNames(connection))
          .contains(
              "lc_meta_tenant",
              "lc_meta_workspace",
              "lc_meta_app",
              "lc_meta_object",
              "lc_meta_page",
              "lc_meta_role",
              "lc_meta_datasource",
              "lc_meta_version",
              "lc_meta_plugin",
              "lc_meta_ref",
              "lc_rt_physical_schema",
              "lc_rt_ddl_log",
              "lc_meta_publish_task");
      assertThat(columnNames(connection, "lc_meta_publish_task"))
          .contains("plan_json", "fencing_token", "trace_id", "publish_status");
      assertThat(columnNames(connection, "lc_meta_object"))
          .contains("object_category", "source_kind", "base_object_code", "extension_policy");
    }
  }

  private static Set<String> tableNames(Connection connection) throws SQLException {
    Set<String> tables = new HashSet<>();
    try (ResultSet resultSet = connection.getMetaData().getTables(null, null, "lc_%", null)) {
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
}
