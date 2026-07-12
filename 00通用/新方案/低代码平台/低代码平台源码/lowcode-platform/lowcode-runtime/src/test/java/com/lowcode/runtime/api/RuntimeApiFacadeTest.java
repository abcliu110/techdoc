package com.lowcode.runtime.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.runtime.data.AddRecordCommand;
import com.lowcode.runtime.data.DeleteRecordCommand;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.FieldKind;
import com.lowcode.runtime.data.ListRecordCommand;
import com.lowcode.runtime.data.StateMachineDefinition;
import com.lowcode.runtime.data.TransitionCommand;
import com.lowcode.runtime.data.UpdateRecordCommand;
import com.lowcode.runtime.data.UpdateRecordResult;
import com.lowcode.runtime.permission.AccessExplain;
import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.DataScope;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuntimeApiFacadeTest {

  @Test
  void shouldExposeDynamicCrudTransitionExportPermissionExplainAndMetrics() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("secret_amount", FieldKind.CURRENCY)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
    RuntimeRequestContext context = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-1");

    String lid = api.add(context, new AddRecordCommand(
        Map.of("amount", "12000", "remark", "待审批"),
        "mh-1",
        "idem-add")).recordLid();

    assertThat(api.list(context, new ListRecordCommand(Set.of("amount", "secret_amount"), List.of(), List.of(), 1, 20)))
        .singleElement()
        .satisfies(row -> {
          assertThat(row).containsEntry("lid", lid);
          assertThat(row).doesNotContainKey("secret_amount");
        });

    assertThatThrownBy(() -> api.update(context, new UpdateRecordCommand(lid, 1L, Map.of("state_code", "approved"), "mh-1")))
        .isInstanceOf(RuntimeApiException.class)
        .hasMessageContaining("普通更新不能修改状态字段");

    api.transition(context, new TransitionCommand(lid, "approve", Map.of("approval_comment", "同意"), "mh-1", "idem-tr"));

    assertThat(api.export(context, Set.of("amount", "secret_amount")).getFirst())
        .doesNotContainKey("secret_amount");
    assertThat(api.explain(context, Operation.UPDATE).reasons()).contains("运行态默认权限通过");
    assertThat(api.metrics()).extracting(PlatformMetricEvent::metricCode)
        .contains("record.created", "state.transitioned");
    assertThat(api.metrics()).allSatisfy(metric -> assertThat(metric.tags()).doesNotContainKey("secret_amount"));
  }

  @Test
  void shouldFailFastWhenTenantMissingAndRejectStaleMetaHash() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .build());

    RuntimeRequestContext noTenant = new RuntimeRequestContext(null, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-1");
    assertThatThrownBy(() -> api.add(noTenant, new AddRecordCommand(Map.of("amount", "1"), "mh-1", "idem-1")))
        .isInstanceOf(RuntimeApiException.class)
        .hasMessageContaining("租户不能为空");

    RuntimeRequestContext context = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-new", "trace-2");
    assertThatThrownBy(() -> api.add(context, new AddRecordCommand(Map.of("amount", "1"), "mh-old", "idem-2")))
        .isInstanceOf(RuntimeApiException.class)
        .hasMessageContaining("元数据版本已过期");
  }

  @Test
  void shouldImportPreviewAndCommitThroughDataWriteServiceIdempotently() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("customer", "lc_rt_customer")
        .field("name", FieldKind.TEXT)
        .field("level", FieldKind.TEXT)
        .build());
    RuntimeRequestContext context = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "customer", "mh-1", "trace-3");

    ImportPreview preview = api.importPreview(context, List.of(Map.of("name", "金蝶客户", "level", "vip")));
    ImportCommitResult first = api.importCommit(context, preview.taskId(), "import-idem");
    ImportCommitResult replay = api.importCommit(context, preview.taskId(), "import-idem");

    assertThat(preview.errors()).isEmpty();
    assertThat(first.createdCount()).isEqualTo(1);
    assertThat(replay.createdCount()).isEqualTo(1);
    assertThat(api.list(context, new ListRecordCommand(Set.of("name", "level"), List.of(), List.of(), 1, 20))).hasSize(1);
  }

  @Test
  void shouldRejectImportCommitFromDifferentWorkspace() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .build());
    RuntimeRequestContext previewContext = new RuntimeRequestContext(1L, 70L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-import");
    RuntimeRequestContext otherWorkspace = new RuntimeRequestContext(1L, 80L, "u2", Set.of("manager"), "sales", "order", "mh-1", "trace-import-other");

    ImportPreview preview = api.importPreview(previewContext, List.of(Map.of("amount", "100", "remark", "workspace-70")));

    assertThatThrownBy(() -> api.importCommit(otherWorkspace, preview.taskId(), "import-idem"))
        .isInstanceOf(RuntimeApiException.class);
    assertThat(api.list(otherWorkspace, new ListRecordCommand(Set.of("amount", "remark"), List.of(), List.of(), 1, 20))).isEmpty();
  }

  @Test
  void shouldIsolateDefinitionsForSameObjectCodeAcrossApps() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject("sales", DynamicObjectDefinition.builder("order", "lc_rt_sales_order")
        .field("amount", FieldKind.CURRENCY)
        .build());
    api.registerObject("service", DynamicObjectDefinition.builder("order", "lc_rt_service_order")
        .field("ticketNo", FieldKind.TEXT)
        .build());

    RuntimeRequestContext sales = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-sales");
    RuntimeRequestContext service = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "service", "order", "mh-1", "trace-service");

    api.add(sales, new AddRecordCommand(Map.of("amount", "12"), "mh-1", "idem-sales"));
    api.add(service, new AddRecordCommand(Map.of("ticketNo", "T-1"), "mh-1", "idem-service"));

    assertThat(api.meta(sales).fields()).containsExactly("amount");
    assertThat(api.meta(service).fields()).containsExactly("ticketNo");
    assertThat(api.list(sales, new ListRecordCommand(Set.of("amount"), List.of(), List.of(), 1, 20)))
        .singleElement()
        .satisfies(row -> assertThat(row).containsEntry("amount", new java.math.BigDecimal("12")));
    assertThat(api.list(service, new ListRecordCommand(Set.of("ticketNo"), List.of(), List.of(), 1, 20)))
        .singleElement()
        .satisfies(row -> assertThat(row).containsEntry("ticketNo", "T-1"));
  }

  @Test
  void shouldExposeMetaGetSuggestDeleteAndStableErrorCode() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("secret_amount", FieldKind.CURRENCY)
        .build());
    RuntimeRequestContext context = new RuntimeRequestContext(9L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-9");

    String lid = api.add(context, new AddRecordCommand(
        Map.of("amount", "88", "remark", "候选订单"),
        "mh-1",
        "idem-meta")).recordLid();

    assertThat(api.meta(context).fields()).containsExactly("amount", "remark", "secret_amount");
    assertThat(api.get(context, lid, Set.of("amount", "secret_amount")))
        .containsEntry("amount", new java.math.BigDecimal("88"))
        .doesNotContainKey("secret_amount");
    assertThat(api.suggest(context, "候选", Set.of("remark"), 5).getFirst())
        .containsEntry("lid", lid);
    assertThat(api.delete(context, new DeleteRecordCommand(lid, 1L, "mh-1")).deleted()).isTrue();
    assertThat(api.list(context, new ListRecordCommand(Set.of("amount"), List.of(), List.of(), 1, 20))).isEmpty();

    RuntimeRequestContext noTenant = new RuntimeRequestContext(null, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-10");
    assertThatThrownBy(() -> api.list(noTenant, new ListRecordCommand(Set.of("amount"), List.of(), List.of(), 1, 20)))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("TENANT_REQUIRED");
  }

  @Test
  void shouldReplayUpdateWithSameIdempotencyKeyWithoutIncrementingRevisionAgain() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .build());
    RuntimeRequestContext context = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-update-idem");

    String lid = api.add(context, new AddRecordCommand(
        Map.of("amount", "88", "remark", "original"),
        "mh-1",
        "idem-update-add")).recordLid();

    UpdateRecordResult first = api.update(context, new UpdateRecordCommand(
        lid,
        1L,
        Map.of("remark", "updated"),
        "mh-1",
        "idem-update-1"));
    UpdateRecordResult replay = api.update(context, new UpdateRecordCommand(
        lid,
        1L,
        Map.of("remark", "updated"),
        "mh-1",
        "idem-update-1"));

    assertThat(first.revision()).isEqualTo(2L);
    assertThat(replay.revision()).isEqualTo(2L);
    assertThat(api.get(context, lid, Set.of("remark"))).containsEntry("remark", "updated");
  }

  @Test
  void shouldProtectGetDeleteActionAndImportCommitBoundaries() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
    RuntimeRequestContext context = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-boundary");

    String lid = api.add(context, new AddRecordCommand(Map.of("amount", "12", "remark", "safe"), "mh-1", "idem-boundary"))
        .recordLid();

    assertThatThrownBy(() -> api.get(context, lid, Set.of("remark or 1=1")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("SQL_WHITELIST_VIOLATION");
    assertThatThrownBy(() -> api.delete(context, new DeleteRecordCommand(lid, 99L, "mh-1")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("REVISION_CONFLICT");
    assertThatThrownBy(() -> api.transition(context, new TransitionCommand(lid, "reject", Map.of(), "mh-1", "idem-reject")))
        .isInstanceOf(RuntimeApiException.class);

    ImportPreview badPreview = api.importPreview(context, List.of(Map.of("amount", "1", "unsafe", "x")));
    assertThat(badPreview.errors()).isNotEmpty();
    assertThatThrownBy(() -> api.importCommit(context, badPreview.taskId(), "bad-import"))
        .isInstanceOf(RuntimeApiException.class);

    api.delete(context, new DeleteRecordCommand(lid, 1L, "mh-1"));
    assertThatThrownBy(() -> api.get(context, lid, Set.of("remark")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("RECORD_NOT_FOUND");
  }

  @Test
  void shouldDenyAllOperationsWhenRoleCodesEmpty() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
    RuntimeRequestContext noRoleContext = new RuntimeRequestContext(1L, 1L, "u1", Set.of(), "sales", "order", "mh-1", "trace-no-role");

    assertThat(api.explain(noRoleContext, Operation.READ).allowed()).isFalse();
    assertThat(api.explain(noRoleContext, Operation.READ).reasons()).contains("运行态默认权限拒绝");
    assertThatThrownBy(() -> api.add(noRoleContext, new AddRecordCommand(Map.of("amount", "12", "remark", "safe"), "mh-1", "idem-no-role")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("PERMISSION_DENIED");
  }

  @Test
  void shouldAllowOnlyDeclaredRoleActionsForTransition() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
    RuntimeRequestContext managerContext = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-manager");
    RuntimeRequestContext clerkContext = new RuntimeRequestContext(1L, 1L, "u2", Set.of("clerk"), "sales", "order", "mh-1", "trace-clerk");

    String lid = api.add(managerContext, new AddRecordCommand(Map.of("amount", "12", "remark", "safe"), "mh-1", "idem-manager"))
        .recordLid();

    assertThatThrownBy(() -> api.transition(clerkContext, new TransitionCommand(lid, "approve", Map.of("approval_comment", "同意"), "mh-1", "idem-clerk")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("PERMISSION_DENIED");
  }

  @Test
  void shouldRequireTenantContextForPermissionExplain() {
    RuntimeApiFacade api = new RuntimeApiFacade();
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .build());

    RuntimeRequestContext noTenant = new RuntimeRequestContext(null, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-explain-no-tenant");

    assertThatThrownBy(() -> api.explain(noTenant, Operation.READ))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("TENANT_REQUIRED");
  }

  @Test
  void shouldHonorPermissionCenterForObjectAndActionDenials() {
    RuntimeApiFacade api = new RuntimeApiFacade((requestContext, definition) -> {
      java.util.Map<String, FieldAccess> fieldView = new java.util.LinkedHashMap<>();
      definition.fields().keySet().forEach(field -> fieldView.put(field, FieldAccess.WRITE));
      if ("blocked".equals(requestContext.objectCode())) {
        return new AccessView(
            requestContext.objectCode(),
            Set.of(),
            Map.copyOf(fieldView),
            DataScope.self(),
            Set.of(),
            requestContext.metaHash(),
            9L,
            new AccessExplain(false, List.of("权限中心拒绝对象访问")));
      }
      return new AccessView(
          requestContext.objectCode(),
          Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE, Operation.DELETE, Operation.EXPORT, Operation.IMPORT, Operation.TRANSITION),
          Map.copyOf(fieldView),
          DataScope.self(),
          Set.of(),
          requestContext.metaHash(),
          9L,
          AccessExplain.allow("权限中心允许对象，但未授予动作权限"));
    });
    api.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
    api.registerObject(DynamicObjectDefinition.builder("blocked", "lc_rt_blocked")
        .field("amount", FieldKind.CURRENCY)
        .build());

    RuntimeRequestContext allowedContext = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "order", "mh-1", "trace-policy-allow");
    RuntimeRequestContext blockedContext = new RuntimeRequestContext(1L, 1L, "u1", Set.of("manager"), "sales", "blocked", "mh-1", "trace-policy-blocked");

    assertThatThrownBy(() -> api.add(blockedContext, new AddRecordCommand(Map.of("amount", "12"), "mh-1", "idem-blocked")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("PERMISSION_DENIED");

    String lid = api.add(allowedContext, new AddRecordCommand(Map.of("amount", "12"), "mh-1", "idem-allow")).recordLid();

    assertThatThrownBy(() -> api.transition(allowedContext, new TransitionCommand(lid, "approve", Map.of("approval_comment", "同意"), "mh-1", "idem-denied-action")))
        .isInstanceOf(RuntimeApiException.class)
        .extracting(ex -> ((RuntimeApiException) ex).code())
        .isEqualTo("PERMISSION_DENIED");
  }

  private static AccessView managerAccess() {
    return new AccessView(
        "order",
        Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE, Operation.TRANSITION, Operation.EXPORT, Operation.IMPORT),
        Map.of("amount", FieldAccess.WRITE, "remark", FieldAccess.WRITE, "secret_amount", FieldAccess.NONE,
            "approval_comment", FieldAccess.WRITE),
        DataScope.self(),
        Set.of("approve"),
        "mh-1",
        1L,
        com.lowcode.runtime.permission.AccessExplain.allow("运行态默认权限通过"));
  }
}
