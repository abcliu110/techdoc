package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class SchemaSyncExecutorTest {

  @Test
  void execute_第三步失败_保留前两步成功和第三步失败日志() {
    DdlPlan plan =
        new DdlPlan(
            1L,
            10L,
            List.of(
                step(1, DdlType.CREATE_TABLE, "create table lc_crm_order (id bigint primary key)"),
                step(2, DdlType.ADD_COLUMN, "alter table lc_crm_order add column name varchar(64)"),
                step(3, DdlType.ADD_COLUMN, "alter table lc_crm_order add column amount decimal(18,4)")));
    SchemaSyncExecutor executor = new SchemaSyncExecutor(step -> step.stepNo() == 3);

    DdlExecutionReport report = executor.execute(plan);

    assertThat(report.success()).isFalse();
    assertThat(report.failedStepNo()).isEqualTo(3);
    assertThat(executor.logs()).extracting(DdlExecutionLog::status).containsExactly("success", "success", "failed");
    assertThat(executor.logs()).extracting(DdlExecutionLog::stepNo).containsExactly(1, 2, 3);
  }

  @Test
  void execute_计划存在阻断项_不执行任何SQL并记录阻断日志() {
    DdlPlan plan =
        new DdlPlan(
            1L,
            10L,
            List.of(new DdlStep(1, DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE, "order", "lc_crm_order", "tags", "", false)));

    SchemaSyncExecutor executor = new SchemaSyncExecutor();
    DdlExecutionReport report = executor.execute(plan);

    assertThat(report.success()).isFalse();
    assertThat(report.failedStepNo()).isEqualTo(1);
    assertThat(executor.logs()).singleElement().satisfies(log -> {
      assertThat(log.status()).isEqualTo("blocked");
      assertThat(log.ddlType()).isEqualTo(DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE);
    });
  }

  private static DdlStep step(int stepNo, DdlType type, String sql) {
    return new DdlStep(stepNo, type, "order", "lc_crm_order", null, sql, true);
  }
}
