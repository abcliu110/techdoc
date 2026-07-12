package com.lowcode.app.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.FieldKind;
import com.lowcode.runtime.permission.AccessExplain;
import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.DataScope;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuntimeApiHttpFacadeTest {

  @Test
  void shouldDelegateHttpContractToRuntimeApiFacade() {
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiWithOrderObject());
    AuthenticatedRuntimeContext context = managerContext(70L, "trace-runtime-http");

    AddRecordResponse added = facade.add(context, new AddRecordRequest(
        "mh-1",
        "http-runtime-add",
        Map.of("amount", "12000", "remark", "runtime api")));

    assertThat(added.revision()).isEqualTo(1L);
    assertThat(facade.list(context, new ListRequest(Set.of("amount", "secret_amount"), List.of(), List.of(), 1, 20)))
        .singleElement()
        .satisfies(row -> {
          assertThat(row).containsEntry("lid", added.recordLid());
          assertThat(row).containsEntry("amount", new java.math.BigDecimal("12000"));
          assertThat(row).doesNotContainKey("secret_amount");
        });
    assertThat(facade.explain(context, new PermissionExplainRequest("sales", "order", "UPDATE")).allowed()).isTrue();
  }

  @Test
  void shouldKeepImportPreviewScopedToWorkspaceWhenDelegating() {
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiWithOrderObject());
    AuthenticatedRuntimeContext workspace70 = managerContext(70L, "trace-runtime-import");
    AuthenticatedRuntimeContext workspace80 = managerContext(80L, "trace-runtime-import-other");

    ImportPreviewResponse preview = facade.importPreview(
        workspace70,
        new ImportPreviewRequest(List.of(Map.of("amount", "100", "remark", "workspace-70"))));

    assertThatThrownBy(() -> facade.importCommit(workspace80, new ImportCommitRequest(preview.taskId(), "import-idem")))
        .isInstanceOf(RuntimeException.class);
    assertThat(facade.list(workspace80, new ListRequest(Set.of("amount", "remark"), List.of(), List.of(), 1, 20))).isEmpty();
  }

  @Test
  void shouldReplayUpdateWithSameIdempotencyKeyWithoutIncrementingRevisionAgain() {
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiWithOrderObject());
    AuthenticatedRuntimeContext context = managerContext(70L, "trace-runtime-update-idempotency");

    AddRecordResponse added = facade.add(context, new AddRecordRequest(
        "mh-1",
        "http-runtime-update-add",
        Map.of("amount", "12000", "remark", "before update")));
    UpdateRecordRequest request = new UpdateRecordRequest(
        added.recordLid(),
        added.revision(),
        "mh-1",
        "http-runtime-update-idem",
        Map.of("remark", "after update"));

    UpdateRecordResponse first = facade.update(context, request);
    UpdateRecordResponse replay = facade.update(context, request);

    assertThat(first.revision()).isEqualTo(2L);
    assertThat(replay.revision()).isEqualTo(2L);
    assertThat(facade.get(context, new RecordReadRequest(added.recordLid(), Set.of("remark"))))
        .containsEntry("remark", "after update");
  }

  @Test
  void shouldSurfacePermissionCenterDenialsThroughHttpFacade() {
    RuntimeApiFacade runtimeApiFacade = new RuntimeApiFacade((requestContext, definition) -> {
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
            7L,
            new AccessExplain(false, List.of("权限中心拒绝对象访问")));
      }
      return new AccessView(
          requestContext.objectCode(),
          Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE, Operation.DELETE, Operation.EXPORT, Operation.IMPORT),
          Map.copyOf(fieldView),
          DataScope.self(),
          Set.of(),
          requestContext.metaHash(),
          7L,
          AccessExplain.allow("权限中心允许演示对象访问"));
    });
    runtimeApiFacade.registerObject(DynamicObjectDefinition.builder("blocked", "lc_rt_blocked")
        .field("amount", FieldKind.CURRENCY)
        .build());
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiFacade);
    AuthenticatedRuntimeContext blockedContext = new AuthenticatedRuntimeContext(
        3L,
        70L,
        "manager-1",
        Set.of("manager"),
        "sales",
        "blocked",
        "mh-1",
        "trace-runtime-http-denied");

    assertThatThrownBy(() -> facade.add(blockedContext, new AddRecordRequest(
        "mh-1",
        "http-runtime-denied",
        Map.of("amount", "1"))))
        .isInstanceOf(RuntimeException.class)
        .hasMessageContaining("无操作权限");
  }

  @Test
  void shouldNotRegisterHardcodedDemoObjectWhenRegistryIsMissing() {
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(new RuntimeApiFacade());
    AuthenticatedRuntimeContext context = managerContext(70L, "trace-runtime-no-demo");

    assertThatThrownBy(() -> facade.meta(context))
        .isInstanceOf(RuntimeException.class)
        .hasMessageContaining("对象不存在");
  }

  private static AuthenticatedRuntimeContext managerContext(Long workspaceId, String traceId) {
    return new AuthenticatedRuntimeContext(
        3L,
        workspaceId,
        "manager-1",
        Set.of("manager"),
        "sales",
        "order",
        "mh-1",
        traceId);
  }

  private static RuntimeApiFacade runtimeApiWithOrderObject() {
    RuntimeApiFacade runtimeApiFacade = new RuntimeApiFacade();
    runtimeApiFacade.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("secret_amount", FieldKind.CURRENCY)
        .build());
    return runtimeApiFacade;
  }
}
