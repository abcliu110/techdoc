package com.lowcode.workflow.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.io.ByteArrayOutputStream;
import java.io.ObjectOutputStream;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class WorkflowRuntimeServiceTest {

  @Test
  void shouldPinRunningInstanceToDefinitionVersionAndSupportManualIntervention() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager")));
    String instanceLid = service.start("expense", "record-1", "trace-1");
    service.publish(new WorkflowDefinition("expense", "v2", Map.of("approve", "director")));

    WorkflowTask task = service.createApprovalTask(instanceLid, "approve");
    service.failNode(instanceLid, "approve", "外部服务超时");
    service.markManualIntervention(instanceLid, "approve", "转人工处理");

    assertThat(service.instance(instanceLid).definitionVersion()).isEqualTo("v1");
    assertThat(task.assigneeRole()).isEqualTo("manager");
    assertThat(service.impactReport("expense", "manager").affectedInstanceLids()).contains(instanceLid);
    assertThat(service.metricEvents()).extracting(WorkflowMetricEvent::metricCode).contains("workflow.failed");
  }

  @Test
  void shouldClaimCompleteApprovalTaskAndCountNodeRetries() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager")));
    String instanceLid = service.start("expense", "record-1", "trace-1");
    WorkflowTask task = service.createApprovalTask(instanceLid, "approve");

    WorkflowTask claimed = service.claimTask(task.taskLid(), "user-1");
    WorkflowTask completed = service.completeTask(task.taskLid(), "user-1", "approved");
    service.retryNode(instanceLid, "approve", "timeout");
    service.retryNode(instanceLid, "approve", "timeout");

    assertThat(claimed.status()).isEqualTo(WorkflowTaskStatus.CLAIMED);
    assertThat(completed.status()).isEqualTo(WorkflowTaskStatus.COMPLETED);
    assertThat(completed.assigneeUser()).isEqualTo("user-1");
    assertThat(service.nodeRetryCount(instanceLid, "approve")).isEqualTo(2);
    assertThat(service.metricEvents()).extracting(WorkflowMetricEvent::metricCode)
        .contains("workflow.task_completed", "workflow.node_retry");
  }

  @Test
  void shouldFreezeOldInstanceVersionWhenNewDefinitionPublished() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String oldInstance = service.start("tenant-a", "expense", "record-1", "trace-1", "user-a", true);

    service.publish(new WorkflowDefinition("expense", "v2", Map.of("approve", "director"), 2));
    String newInstance = service.start("tenant-a", "expense", "record-2", "trace-2", "user-a", true);

    WorkflowTask oldTask = service.createApprovalTask("tenant-a", oldInstance, "approve");
    WorkflowTask newTask = service.createApprovalTask("tenant-a", newInstance, "approve");

    assertThat(service.instance("tenant-a", oldInstance).definitionVersion()).isEqualTo("v1");
    assertThat(service.instance("tenant-a", newInstance).definitionVersion()).isEqualTo("v2");
    assertThat(oldTask.assigneeRole()).isEqualTo("manager");
    assertThat(newTask.assigneeRole()).isEqualTo("director");
  }

  @Test
  void shouldBlockDuplicateClaimAndUnauthorizedCompletionAcrossTenants() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String instanceLid = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);
    WorkflowTask task = service.createApprovalTask("tenant-a", instanceLid, "approve");

    WorkflowTask claimed = service.claimTask("tenant-a", task.taskLid(), "user-1", "trace-2");

    assertThat(claimed.status()).isEqualTo(WorkflowTaskStatus.CLAIMED);
    assertThatThrownBy(() -> service.claimTask("tenant-a", task.taskLid(), "user-2", "trace-3"))
        .isInstanceOf(IllegalStateException.class)
        .hasMessageContaining("审批任务已被认领");
    assertThatThrownBy(() -> service.completeTask("tenant-a", task.taskLid(), "user-2", "approved", "trace-4"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("审批任务未由当前用户认领");
    assertThatThrownBy(() -> service.instance("tenant-b", instanceLid))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("工作流实例不存在");
  }

  @Test
  void shouldRetryTimeoutThenEscalateToManualInterventionAndDeadLetter() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String instanceLid = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);

    service.recordNodeTimeout("tenant-a", instanceLid, "approve", Instant.parse("2026-07-06T12:00:00Z"), 2);
    service.retryNode("tenant-a", instanceLid, "approve", "timeout");
    service.recordNodeTimeout("tenant-a", instanceLid, "approve", Instant.parse("2026-07-06T12:05:00Z"), 2);
    service.retryNode("tenant-a", instanceLid, "approve", "timeout");
    service.recordNodeTimeout("tenant-a", instanceLid, "approve", Instant.parse("2026-07-06T12:10:00Z"), 2);

    WorkflowFailureState failureState = service.failureState("tenant-a", instanceLid, "approve");
    assertThat(failureState.status()).isEqualTo(WorkflowFailureStatus.DEAD_LETTER);
    assertThat(failureState.retryCount()).isEqualTo(2);
    assertThat(failureState.manualSuggestion()).contains("人工处理");
    assertThat(service.metricEvents()).extracting(WorkflowMetricEvent::metricCode)
        .contains("workflow.node_timeout", "workflow.node_dead_letter", "workflow.manual_intervention");
  }

  @Test
  void shouldRecordTimelineForReplayAndIdempotentStart() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));

    String first = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);
    String replay = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);
    WorkflowTask task = service.createApprovalTask("tenant-a", first, "approve");
    service.claimTask("tenant-a", task.taskLid(), "user-1", "trace-2");
    service.completeTask("tenant-a", task.taskLid(), "user-1", "approved", "trace-3");

    List<WorkflowTimelineEvent> timeline = service.timeline("tenant-a", first);
    assertThat(replay).isEqualTo(first);
    assertThat(timeline).extracting(WorkflowTimelineEvent::eventType)
        .containsExactly("INSTANCE_STARTED", "TASK_CREATED", "TASK_CLAIMED", "TASK_COMPLETED");
    assertThat(service.instance("tenant-a", first).startedBy()).isEqualTo("starter-a");
  }

  @Test
  void shouldRejectStartWithoutPermissionAndCreateCompatibilityReportForFrozenInstance() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));

    assertThatThrownBy(() -> service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", false))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("无权限启动流程");

    String instanceLid = service.start("tenant-a", "expense", "record-2", "trace-2", "starter-a", true);
    service.publish(new WorkflowDefinition("expense", "v2", Map.of("review", "director"), 2));

    WorkflowCompatibilityReport report = service.compatibilityReport("tenant-a", instanceLid, "expense");
    assertThat(report.strategy()).isEqualTo("PINNED_OLD_VERSION");
    assertThat(report.risks()).contains("节点删除", "角色变化");
  }

  @Test
  void shouldReuseRepositoryStateAcrossServiceRestartAndKeepPinnedDefinitionForInflightInstance() {
    WorkflowRepository repository = new InMemoryWorkflowRepository();
    WorkflowRuntimeService firstService = new WorkflowRuntimeService(repository);
    firstService.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String inflightInstance = firstService.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);

    WorkflowRuntimeService secondService = new WorkflowRuntimeService(repository);
    secondService.publish(new WorkflowDefinition("expense", "v2", Map.of("approve", "director"), 2));

    WorkflowTask oldTask = secondService.createApprovalTask("tenant-a", inflightInstance, "approve");
    String newInstance = secondService.start("tenant-a", "expense", "record-2", "trace-2", "starter-a", true);
    WorkflowTask newTask = secondService.createApprovalTask("tenant-a", newInstance, "approve");

    assertThat(secondService.instance("tenant-a", inflightInstance).definitionVersion()).isEqualTo("v1");
    assertThat(oldTask.assigneeRole()).isEqualTo("manager");
    assertThat(newTask.assigneeRole()).isEqualTo("director");
  }

  @Test
  void shouldKeepInstanceDefinitionSnapshotWhenPublishedVersionIsOverwritten() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String inflightInstance = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);

    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "director"), 1));

    WorkflowTask task = service.createApprovalTask("tenant-a", inflightInstance, "approve");

    assertThat(service.instance("tenant-a", inflightInstance).definitionVersion()).isEqualTo("v1");
    assertThat(task.assigneeRole()).isEqualTo("manager");
  }

  @Test
  void shouldRecordTimeoutViaCommandBoundary() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String instanceLid = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);

    service.recordNodeTimeout(new WorkflowNodeTimeoutCommand(
        "tenant-a",
        instanceLid,
        "approve",
        Instant.parse("2026-07-06T12:00:00Z"),
        2));

    WorkflowFailureState failureState = service.failureState("tenant-a", instanceLid, "approve");
    assertThat(failureState.status()).isEqualTo(WorkflowFailureStatus.TIMEOUT);
    assertThat(service.metricEvents()).extracting(WorkflowMetricEvent::metricCode)
        .contains("workflow.node_timeout");
  }

  @Test
  void shouldNotWriteFailureStateWhenManualOperationTargetsMissingInstance() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));

    assertThatThrownBy(() -> service.recordNodeTimeout(
            "tenant-a",
            "missing-instance",
            "approve",
            Instant.parse("2026-07-06T12:00:00Z"),
            2))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("工作流实例不存在");
    assertThatThrownBy(() -> service.failureState("tenant-a", "missing-instance", "approve"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("节点失败状态不存在");
    assertThat(service.metricEvents()).isEmpty();

    assertThatThrownBy(() -> service.markManualIntervention(
            "tenant-a",
            "missing-instance",
            "approve",
            "manual review"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("工作流实例不存在");
    assertThatThrownBy(() -> service.failureState("tenant-a", "missing-instance", "approve"))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("节点失败状态不存在");
    assertThat(service.metricEvents()).isEmpty();
  }

  @Test
  void shouldExportSerializableSnapshotForFutureJdbcPersistence() throws Exception {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String instanceLid = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);
    WorkflowTask task = service.createApprovalTask("tenant-a", instanceLid, "approve");
    service.claimTask("tenant-a", task.taskLid(), "user-1", "trace-2");
    service.recordNodeTimeout(
        "tenant-a",
        instanceLid,
        "approve",
        Instant.parse("2026-07-06T12:00:00Z"),
        2);

    WorkflowPersistenceSnapshot snapshot = service.exportPersistenceSnapshots("tenant-a").getFirst();

    assertThat(snapshot.tenantId()).isEqualTo("tenant-a");
    assertThat(snapshot.instance().lid()).isEqualTo(instanceLid);
    assertThat(snapshot.instance().definitionSnapshot().nodeRoleMap()).containsEntry("approve", "manager");
    assertThat(snapshot.tasks()).extracting(WorkflowTaskSnapshot::taskLid).containsExactly(task.taskLid());
    assertThat(snapshot.failures()).extracting(WorkflowFailureSnapshot::status).containsExactly(WorkflowFailureStatus.TIMEOUT);
    assertThat(snapshot.timeline()).extracting(WorkflowTimelineSnapshot::eventType)
        .containsExactly("INSTANCE_STARTED", "TASK_CREATED", "TASK_CLAIMED", "NODE_TIMEOUT");
    assertThat(serialize(snapshot)).isNotEmpty();
  }

  @Test
  void shouldRestoreInMemoryRepositoryFromPersistenceSnapshots() {
    WorkflowRuntimeService service = new WorkflowRuntimeService();
    service.publish(new WorkflowDefinition("expense", "v1", Map.of("approve", "manager"), 1));
    String instanceLid = service.start("tenant-a", "expense", "record-1", "trace-1", "starter-a", true);
    WorkflowTask task = service.createApprovalTask("tenant-a", instanceLid, "approve");
    service.claimTask("tenant-a", task.taskLid(), "user-1", "trace-2");
    service.retryNode("tenant-a", instanceLid, "approve", "timeout");
    service.recordNodeTimeout(
        "tenant-a",
        instanceLid,
        "approve",
        Instant.parse("2026-07-06T12:00:00Z"),
        2);

    InMemoryWorkflowRepository restoredRepository =
        InMemoryWorkflowRepository.restore(service.exportPersistenceSnapshots("tenant-a"));
    WorkflowRuntimeService restoredService = new WorkflowRuntimeService(restoredRepository);
    restoredService.publish(new WorkflowDefinition("expense", "v2", Map.of("review", "director"), 2));

    assertThat(restoredService.instance("tenant-a", instanceLid).definitionVersion()).isEqualTo("v1");
    assertThat(restoredService.instance("tenant-a", instanceLid).definitionSnapshot()).isNotNull();
    assertThat(restoredService.failureState("tenant-a", instanceLid, "approve").retryCount()).isEqualTo(1);
    assertThat(restoredService.nodeRetryCount("tenant-a", instanceLid, "approve")).isEqualTo(1);
    assertThat(restoredService.timeline("tenant-a", instanceLid))
        .extracting(WorkflowTimelineEvent::eventType)
        .containsExactly("INSTANCE_STARTED", "TASK_CREATED", "TASK_CLAIMED", "NODE_RETRIED", "NODE_TIMEOUT");
    assertThat(restoredRepository.tasksByTenant().get("tenant-a"))
        .containsKey(task.taskLid());
    assertThat(restoredService.compatibilityReport("tenant-a", instanceLid, "expense").risks())
        .contains("节点删除", "角色变化");
  }

  private byte[] serialize(Object value) throws Exception {
    ByteArrayOutputStream bytes = new ByteArrayOutputStream();
    try (ObjectOutputStream out = new ObjectOutputStream(bytes)) {
      out.writeObject(value);
    }
    return bytes.toByteArray();
  }
}
