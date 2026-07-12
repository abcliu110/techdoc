package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.DataScope;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class DynamicDataServiceTest {

  @Test
  void shouldKeepTenantIsolationRejectInjectionAndApplyAccessView() {
    DynamicObjectDefinition order = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("secret_amount", FieldKind.CURRENCY)
        .build();
    InMemoryDynamicDataService service = new InMemoryDynamicDataService(order);
    RuntimeExecutionContext tenant1 = context(1L, "sales-1", "mh-1");
    RuntimeExecutionContext tenant2 = context(2L, "sales-2", "mh-1");

    String lid = service.add(tenant1, setupAccess(), new AddRecordCommand(
        Map.of("amount", "12.30", "remark", "first", "secret_amount", "99.00"),
        "mh-1",
        "idem-1")).recordLid();
    service.add(tenant2, setupAccess(), new AddRecordCommand(
        Map.of("amount", "88.00", "remark", "other", "secret_amount", "100.00"),
        "mh-1",
        "idem-2"));

    List<Map<String, Object>> tenant1Rows = service.list(tenant1, access(), new ListRecordCommand(
        Set.of("amount", "remark", "secret_amount"),
        List.of(Filter.eq("amount", new BigDecimal("12.30"))),
        List.of(Sort.asc("amount")),
        1,
        20));

    assertThat(tenant1Rows).hasSize(1);
    assertThat(tenant1Rows.getFirst()).containsEntry("lid", lid);
    assertThat(tenant1Rows.getFirst()).doesNotContainKey("secret_amount");

    assertThatThrownBy(() -> service.list(tenant1, access(), new ListRecordCommand(
            Set.of("amount"),
            List.of(Filter.eq("amount or 1=1", "x")),
            List.of(),
            1,
            20)))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION);
  }

  @Test
  void shouldApplyRuntimeListFiltersAndDescendingSorts() {
    DynamicObjectDefinition order = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .build();
    InMemoryDynamicDataService service = new InMemoryDynamicDataService(order);
    RuntimeExecutionContext tenant1 = context(1L, "sales-1", "mh-1");

    service.add(tenant1, setupAccess(), new AddRecordCommand(Map.of("amount", "8", "remark", "alpha order"), "mh-1", "idem-8"));
    service.add(tenant1, setupAccess(), new AddRecordCommand(Map.of("amount", "12", "remark", "alpha order"), "mh-1", "idem-12"));
    service.add(tenant1, setupAccess(), new AddRecordCommand(Map.of("amount", "18", "remark", "beta order"), "mh-1", "idem-18"));
    service.add(tenant1, setupAccess(), new AddRecordCommand(Map.of("amount", "30", "remark", "alpha order"), "mh-1", "idem-30"));
    service.add(tenant1, setupAccess(), new AddRecordCommand(Map.of("amount", "100", "remark", "beta order"), "mh-1", "idem-100"));

    List<Map<String, Object>> rows = service.list(tenant1, access(), new ListRecordCommand(
        Set.of("amount", "remark"),
        List.of(Filter.gte("amount", "10"), Filter.lte("amount", "100"), Filter.contains("remark", "order")),
        List.of(Sort.desc("amount")),
        1,
        20));

    assertThat(rows).extracting(row -> row.get("amount"))
        .containsExactly(new BigDecimal("100"), new BigDecimal("30"), new BigDecimal("18"), new BigDecimal("12"));
  }

  @Test
  void shouldEnforceMetaHashRevisionStateAndIdempotency() {
    DynamicObjectDefinition order = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build();
    InMemoryDynamicDataService service = new InMemoryDynamicDataService(order);
    RuntimeExecutionContext context = context(1L, "manager-1", "mh-2");
    AddRecordResult first = service.add(context, access(Operation.TRANSITION), new AddRecordCommand(
        Map.of("amount", "12000"),
        "mh-2",
        "idem-add"));
    AddRecordResult replay = service.add(context, access(Operation.TRANSITION), new AddRecordCommand(
        Map.of("amount", "12000"),
        "mh-2",
        "idem-add"));

    assertThat(replay.recordLid()).isEqualTo(first.recordLid());

    assertThatThrownBy(() -> service.update(context, access(), new UpdateRecordCommand(
            first.recordLid(),
            first.revision(),
            Map.of("state_code", "approved"),
            "mh-2")))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.STATE_NOT_EDITABLE);

    assertThatThrownBy(() -> service.transition(context, access(Operation.TRANSITION), new TransitionCommand(
            first.recordLid(),
            "approve",
            Map.of(),
            "mh-2",
            "idem-transition")))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.RULE_VALIDATE_FAILED);

    TransitionResult approved = service.transition(context, access(Operation.TRANSITION), new TransitionCommand(
        first.recordLid(),
        "approve",
        Map.of("approval_comment", "同意"),
        "mh-2",
        "idem-transition"));

    assertThat(approved.toState()).isEqualTo("approved");
    assertThat(service.transitionLogs()).hasSize(1);
    assertThat(service.auditLogs()).hasSize(2);
    assertThat(service.outboxEvents()).extracting(OutboxEvent::eventType)
        .contains("record.created", "state.transitioned");
  }

  private static RuntimeExecutionContext context(Long tenantId, String userLid, String metaHash) {
    return new RuntimeExecutionContext(tenantId, 1L, userLid, Set.of("manager"), "sales", "order", metaHash, "trace-1");
  }

  private static AccessView access(Operation... extra) {
    Set<Operation> operations = new java.util.HashSet<>(Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE));
    operations.addAll(List.of(extra));
    return new AccessView(
        "order",
        operations,
        Map.of("amount", FieldAccess.WRITE, "approval_comment", FieldAccess.WRITE, "remark", FieldAccess.WRITE,
            "secret_amount", FieldAccess.NONE),
        DataScope.self(),
        Set.of("approve"),
        "mh-1",
        1L,
        com.lowcode.runtime.permission.AccessExplain.allow("test"));
  }

  private static AccessView setupAccess() {
    return new AccessView(
        "order",
        Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE),
        Map.of("amount", FieldAccess.WRITE, "approval_comment", FieldAccess.WRITE, "remark", FieldAccess.WRITE,
            "secret_amount", FieldAccess.WRITE),
        DataScope.self(),
        Set.of(),
        "mh-1",
        1L,
        com.lowcode.runtime.permission.AccessExplain.allow("setup"));
  }
}
