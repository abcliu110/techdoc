package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class JdbcDynamicRecordRepositoryTest {

  @Test
  void shouldBuildParameterizedSqlWithTenantAndDeletedGuard() {
    DynamicObjectDefinition order = orderDefinition();
    RuntimeExecutionContext tenant1 = context(1L);
    JdbcDynamicRecordRepository repository = new JdbcDynamicRecordRepository(new RecordingJdbcExecutor());

    DynamicRecord record = new DynamicRecord(
        "01ABCDEFGHABCDEFGHABCDEFGH",
        tenant1.tenantId(),
        Map.of("amount", new BigDecimal("12.30"), "remark", "first"),
        "draft",
        1L,
        false);
    repository.insert(order, tenant1, record);
    List<DynamicRecord> rows = repository.list(order, tenant1, List.of(Filter.eq("amount", "12.30")), List.of(Sort.asc("amount")), 1, 20);
    DynamicRecord current = repository.require(order, tenant1, record.lid());
    repository.update(order, tenant1, current.nextRevision());
    repository.softDelete(order, tenant1, record.lid(), current.revision());

    RecordingJdbcExecutor executor = (RecordingJdbcExecutor) repository.executor();
    assertThat(executor.sqlHistory()).containsExactly(
        "insert into lc_rt_order (tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark) values (?, ?, ?, ?, ?, ?, ?, ?)",
        "select tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark from lc_rt_order where tenant_id = ? and workspace_id = ? and deleted = 0 and amount = ? order by amount asc limit ? offset ?",
        "select tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark from lc_rt_order where tenant_id = ? and workspace_id = ? and deleted = 0 and lid = ?",
        "update lc_rt_order set state_code = ?, amount = ?, remark = ?, revision = ? where tenant_id = ? and workspace_id = ? and lid = ? and deleted = 0 and revision = ?",
        "update lc_rt_order set deleted = 1, revision = revision + 1 where tenant_id = ? and workspace_id = ? and lid = ? and deleted = 0 and revision = ?");
    assertThat(executor.parametersHistory().getFirst()).containsExactly(
        1L,
        1L,
        "01ABCDEFGHABCDEFGHABCDEFGH",
        1L,
        0,
        "draft",
        new BigDecimal("12.30"),
        "first");
    assertThat(executor.parametersHistory().get(1)).containsExactly(1L, 1L, new BigDecimal("12.30"), 20, 0);
    assertThat(executor.parametersHistory().get(2)).containsExactly(1L, 1L, "01ABCDEFGHABCDEFGHABCDEFGH");
    assertThat(executor.parametersHistory().get(3)).containsExactly("draft", new BigDecimal("12.30"), "first", 2L, 1L, 1L, "01ABCDEFGHABCDEFGHABCDEFGH", 1L);
    assertThat(executor.parametersHistory().get(4)).containsExactly(1L, 1L, "01ABCDEFGHABCDEFGHABCDEFGH", 1L);
  }

  @Test
  void shouldBuildWhitelistedFilterAndSortSqlForSupportedOperators() {
    DynamicObjectDefinition order = orderDefinition();
    RuntimeExecutionContext tenant1 = context(1L);
    JdbcDynamicRecordRepository repository = new JdbcDynamicRecordRepository(new RecordingJdbcExecutor());

    repository.list(
        order,
        tenant1,
        List.of(
            Filter.eq("amount", "12.30"),
            new Filter("amount", "gte", "10"),
            new Filter("amount", "lte", "20"),
            new Filter("remark", "contains", "first")),
        List.of(new Sort("amount", "desc"), Sort.asc("remark")),
        2,
        300);

    RecordingJdbcExecutor executor = (RecordingJdbcExecutor) repository.executor();
    assertThat(executor.sqlHistory()).containsExactly(
        "select tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark from lc_rt_order "
            + "where tenant_id = ? and workspace_id = ? and deleted = 0 and amount = ? and amount >= ? and amount <= ? and remark like ? "
            + "order by amount desc, remark asc limit ? offset ?");
    assertThat(executor.parametersHistory().getFirst())
        .containsExactly(1L, 1L, new BigDecimal("12.30"), new BigDecimal("10"), new BigDecimal("20"), "%first%", 200, 200);
  }

  @Test
  void shouldRejectUnknownFieldAndUnsafeMetadataIdentifierBeforeSqlExecution() {
    RuntimeExecutionContext tenant1 = context(1L);
    RecordingJdbcExecutor executor = new RecordingJdbcExecutor();
    JdbcDynamicRecordRepository repository = new JdbcDynamicRecordRepository(executor);

    assertThatThrownBy(() -> repository.list(
            orderDefinition(),
            tenant1,
            List.of(Filter.eq("amount or 1=1", "x")),
            List.of(),
            1,
            20))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION);

    assertThatThrownBy(() -> repository.list(
            orderDefinition(),
            tenant1,
            List.of(new Filter("amount", "eq; drop table x", "12.30")),
            List.of(),
            1,
            20))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION);

    assertThatThrownBy(() -> repository.list(
            orderDefinition(),
            tenant1,
            List.of(),
            List.of(new Sort("amount", "desc; drop table x")),
            1,
            20))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION);

    assertThatThrownBy(() -> repository.list(
            DynamicObjectDefinition.builder("order", "lc_rt_order;drop table x").field("amount", FieldKind.CURRENCY).build(),
            tenant1,
            List.of(),
            List.of(),
            1,
            20))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION);

    assertThat(executor.sqlHistory()).isEmpty();
  }

  @Test
  void shouldAllowDynamicDataServiceToUseJdbcRepositoryBoundary() {
    DynamicObjectDefinition order = orderDefinition();
    RecordingJdbcExecutor executor = new RecordingJdbcExecutor();
    InMemoryDynamicDataService service = new InMemoryDynamicDataService(order, new JdbcDynamicRecordRepository(executor));

    service.add(context(1L), accessView(), new AddRecordCommand(Map.of("amount", "12.30", "remark", "first"), "mh-1", "idem-1"));
    List<Map<String, Object>> rows = service.list(context(1L), accessView(), new ListRecordCommand(
        java.util.Set.of("amount", "remark"),
        List.of(Filter.eq("amount", "12.30")),
        List.of(),
        1,
        20));

    assertThat(rows).hasSize(1);
    assertThat(rows.getFirst()).containsEntry("amount", new BigDecimal("12.30"));
    assertThat(executor.sqlHistory()).contains(
        "insert into lc_rt_order (tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark) values (?, ?, ?, ?, ?, ?, ?, ?)",
        "select tenant_id, workspace_id, lid, revision, deleted, state_code, amount, remark from lc_rt_order where tenant_id = ? and workspace_id = ? and deleted = 0 and amount = ? order by lid asc limit ? offset ?");
  }

  @Test
  void shouldRequireTenantAndWorkspaceForAllJdbcOperations() {
    DynamicObjectDefinition order = orderDefinition();
    JdbcDynamicRecordRepository repository = new JdbcDynamicRecordRepository(new RecordingJdbcExecutor());
    DynamicRecord record = new DynamicRecord(
        "01ABCDEFGHABCDEFGHABCDEFGH",
        1L,
        Map.of("amount", new BigDecimal("12.30"), "remark", "first"),
        "draft",
        1L,
        false);

    assertThatThrownBy(() -> repository.insert(order, context(null, 1L), record))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.TENANT_REQUIRED);
    assertThatThrownBy(() -> repository.list(order, context(1L, null), List.of(), List.of(), 1, 20))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.TENANT_REQUIRED);
    assertThatThrownBy(() -> repository.require(order, context(1L, null), record.lid()))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.TENANT_REQUIRED);
    assertThatThrownBy(() -> repository.update(order, context(1L, null), record.nextRevision()))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.TENANT_REQUIRED);
    assertThatThrownBy(() -> repository.softDelete(order, context(1L, null), record.lid(), 1L))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.TENANT_REQUIRED);
  }

  private static DynamicObjectDefinition orderDefinition() {
    return DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", java.util.Set.of("manager")))
        .build();
  }

  private static RuntimeExecutionContext context(Long tenantId) {
    return context(tenantId, 1L);
  }

  private static RuntimeExecutionContext context(Long tenantId, Long workspaceId) {
    return new RuntimeExecutionContext(tenantId, workspaceId, "u1", java.util.Set.of("manager"), "sales", "order", "mh-1", "trace-1");
  }

  private static com.lowcode.runtime.permission.AccessView accessView() {
    return new com.lowcode.runtime.permission.AccessView(
        "order",
        java.util.Set.of(
            com.lowcode.runtime.permission.Operation.READ,
            com.lowcode.runtime.permission.Operation.CREATE,
            com.lowcode.runtime.permission.Operation.UPDATE),
        Map.of(
            "amount", com.lowcode.runtime.permission.FieldAccess.WRITE,
            "remark", com.lowcode.runtime.permission.FieldAccess.WRITE),
        com.lowcode.runtime.permission.DataScope.self(),
        java.util.Set.of(),
        "mh-1",
        1L,
        com.lowcode.runtime.permission.AccessExplain.allow("test"));
  }
}
