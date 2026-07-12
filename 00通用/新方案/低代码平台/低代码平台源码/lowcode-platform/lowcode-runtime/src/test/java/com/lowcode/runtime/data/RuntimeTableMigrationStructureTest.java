package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;

class RuntimeTableMigrationStructureTest {

  private static final String MIGRATION = "db/migration/V202607060001__create_runtime_tables.sql";
  private static final String IDEMPOTENCY_WORKSPACE_MIGRATION = "db/migration/V202607070001__scope_runtime_idempotency_by_workspace.sql";

  @Test
  void migration_shouldDeclareRuntimeSideEffectTables() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "create table lc_rt_idempotency",
            "create table lc_rt_audit_log",
            "create table lc_rt_outbox",
            "create table lc_rt_transition_log");
  }

  @Test
  void idempotency_shouldBeTenantAppObjectScopedAndUnique() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "tenant_id bigint not null",
            "app_code varchar(64) not null",
            "object_code varchar(64) not null",
            "operation varchar(32) not null",
            "idempotency_key varchar(128) not null",
            "record_lid varchar(26) not null",
            "unique key uk_lc_rt_idempotency_scope (tenant_id, app_code, object_code, operation, idempotency_key)");
  }

  @Test
  void idempotencyWorkspaceMigration_shouldAddWorkspaceToReplayScope() throws IOException {
    String sql = readMigration(IDEMPOTENCY_WORKSPACE_MIGRATION);

    assertThat(sql)
        .contains(
            "add column workspace_id bigint null",
            "update lc_rt_idempotency set workspace_id = 0 where workspace_id is null",
            "modify column workspace_id bigint not null",
            "unique key uk_lc_rt_idempotency_scope (tenant_id, workspace_id, app_code, object_code, operation, idempotency_key)");
  }

  @Test
  void outboxAndAudit_shouldContainTraceAndMetaContextWithoutBusinessValueColumns() throws IOException {
    String sql = readMigration();

    assertThat(sql)
        .contains(
            "trace_id varchar(64) not null",
            "meta_hash varchar(128) not null",
            "perm_version bigint not null",
            "event_type varchar(64) not null",
            "record_lid varchar(26) not null");
    assertThat(sql).doesNotContain("field_value", "business_value", "raw_payload");
  }

  private static String readMigration() throws IOException {
    return readMigration(MIGRATION);
  }

  private static String readMigration(String migration) throws IOException {
    try (var input = RuntimeTableMigrationStructureTest.class.getClassLoader().getResourceAsStream(migration)) {
      assertThat(input).as("runtime migration resource").isNotNull();
      return new String(input.readAllBytes(), StandardCharsets.UTF_8).toLowerCase();
    }
  }
}
