package com.lowcode.metamodel.dao.migration;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;

class MetaTableMigrationStructureTest {

  private static final String MIGRATION =
      "db/migration/V202607050001__create_meta_tables.sql";

  @Test
  void migration_shouldDeclareM0MetadataTables() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "create table lc_meta_tenant",
            "create table lc_meta_workspace",
            "create table lc_meta_app",
            "create table lc_meta_object",
            "create table lc_meta_page",
            "create table lc_meta_role",
            "create table lc_meta_datasource",
            "create table lc_meta_version",
            "create table lc_meta_plugin",
            "create table lc_meta_ref",
            "create table lc_rt_physical_schema",
            "create table lc_rt_ddl_log",
            "create table lc_meta_publish_task");
  }

  @Test
  void migration_shouldUseStandardColumnsAndDeleteTokenUniqueness() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "tenant_id bigint not null",
            "revision bigint not null default 0",
            "deleted tinyint not null default 0",
            "delete_token bigint not null default 0");
    assertThat(sql).contains("uk_lc_meta_object_app_code_alive (tenant_id, app_id, code, delete_token)");
    assertThat(sql).doesNotContain("deleted_at)");
  }

  @Test
  void publishTask_shouldContainPlanFencingTraceAndStatusColumns() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "task_no varchar(64) not null",
            "publish_status varchar(32) not null",
            "plan_json json null",
            "fencing_token bigint not null default 0",
            "trace_id varchar(64) not null");
  }

  private static String readMigration() throws IOException {
    try (var input =
        MetaTableMigrationStructureTest.class.getClassLoader().getResourceAsStream(MIGRATION)) {
      assertThat(input).as("migration resource").isNotNull();
      return new String(input.readAllBytes(), StandardCharsets.UTF_8).toLowerCase();
    }
  }
}
