package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class PublishStateMachineTest {

  @Test
  void submit_可执行计划_状态推进到完成并保留执行日志() {
    PublishStateMachine stateMachine = new PublishStateMachine(new SchemaSyncExecutor());

    PublishTask task = stateMachine.submit("publish-001", plan(step(1, DdlType.CREATE_TABLE, true)));

    assertThat(task.status()).isEqualTo(PublishTaskStatus.DONE);
    assertThat(task.history()).containsExactly(
        PublishTaskStatus.VALIDATING,
        PublishTaskStatus.PLANNING,
        PublishTaskStatus.LOCKED,
        PublishTaskStatus.EXECUTING,
        PublishTaskStatus.SNAPSHOTTING,
        PublishTaskStatus.ACTIVATING,
        PublishTaskStatus.DONE);
    assertThat(task.executionReport().success()).isTrue();
  }

  @Test
  void submit_同一任务号重复提交_返回已有任务且不重复执行() {
    SchemaSyncExecutor executor = new SchemaSyncExecutor();
    PublishStateMachine stateMachine = new PublishStateMachine(executor);

    PublishTask first = stateMachine.submit("publish-001", plan(step(1, DdlType.CREATE_TABLE, true)));
    PublishTask second = stateMachine.submit("publish-001", plan(step(1, DdlType.CREATE_TABLE, true)));

    assertThat(second).isSameAs(first);
    assertThat(executor.logs()).hasSize(1);
  }

  @Test
  void submit_存在阻断计划_停在失败状态并记录失败步骤() {
    PublishStateMachine stateMachine = new PublishStateMachine(new SchemaSyncExecutor());

    PublishTask task = stateMachine.submit("publish-001", plan(step(1, DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE, false)));

    assertThat(task.status()).isEqualTo(PublishTaskStatus.FAILED_AT);
    assertThat(task.executionReport().failedStepNo()).isEqualTo(1);
    assertThat(task.history()).contains(PublishTaskStatus.VALIDATING, PublishTaskStatus.PLANNING, PublishTaskStatus.EXECUTING, PublishTaskStatus.FAILED_AT);
  }

  @Test
  void resume_失败任务先运行对账_再从原计划继续执行() {
    SchemaSyncExecutor failedExecutor = new SchemaSyncExecutor(step -> step.stepNo() == 2);
    PublishStateMachine stateMachine = new PublishStateMachine(failedExecutor);
    PublishTask failed = stateMachine.submit("publish-001", plan(step(1, DdlType.ADD_COLUMN, true), step(2, DdlType.ADD_COLUMN, true)));
    assertThat(failed.status()).isEqualTo(PublishTaskStatus.FAILED_AT);

    SchemaReconciler reconciler = new SchemaReconciler();
    PublishTask resumed = stateMachine.resume("publish-001", reconciler, SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(), List.of()), new SchemaSyncExecutor());

    assertThat(resumed.status()).isEqualTo(PublishTaskStatus.DONE);
    assertThat(resumed.history()).contains(PublishTaskStatus.RECONCILING, PublishTaskStatus.EXECUTING, PublishTaskStatus.DONE);
    assertThat(resumed.reconcileReport()).isNotNull();
  }

  @Test
  void abandon_失败任务_标记为已废弃且保留恢复建议() {
    PublishStateMachine stateMachine = new PublishStateMachine(new SchemaSyncExecutor(step -> true));
    stateMachine.submit("publish-001", plan(step(1, DdlType.ADD_COLUMN, true)));

    PublishTask abandoned = stateMachine.abandon("publish-001", "人工确认本轮发布废弃");

    assertThat(abandoned.status()).isEqualTo(PublishTaskStatus.ABANDONED);
    assertThat(abandoned.recoveryHint()).contains("人工确认本轮发布废弃");
  }

  @Test
  void continueWithToken_旧fencingToken不能推进任务() {
    PublishStateMachine stateMachine = new PublishStateMachine(new SchemaSyncExecutor());
    PublishTask task = stateMachine.submit("publish-001", plan(step(1, DdlType.ADD_COLUMN, true)));

    PublishTask rejected = stateMachine.continueWithToken("publish-001", task.fencingToken() + "-old", PublishTaskStatus.ACTIVATING);

    assertThat(rejected.status()).isEqualTo(PublishTaskStatus.FAILED_AT);
    assertThat(rejected.errorCode()).isEqualTo("LC-META-PUBLISH-FENCING");
  }

  private static DdlPlan plan(DdlStep... steps) {
    return new DdlPlan(1L, 10L, List.of(steps));
  }

  private static DdlStep step(int stepNo, DdlType type, boolean executable) {
    return new DdlStep(stepNo, type, "order", "lc_crm_order", null, executable ? "create table lc_crm_order (id bigint)" : "", executable);
  }
}
