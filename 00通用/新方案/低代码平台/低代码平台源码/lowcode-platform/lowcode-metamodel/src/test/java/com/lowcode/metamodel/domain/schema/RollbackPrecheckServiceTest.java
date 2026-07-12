package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;

class RollbackPrecheckServiceTest {

  private final RollbackPrecheckService service = new RollbackPrecheckService();

  @Test
  void inspect_新增表和新增列_允许元数据回滚但提示物理结构需人工清理() {
    DdlPlan plan =
        new DdlPlan(
            1L,
            10L,
            List.of(
                new DdlStep(1, DdlType.CREATE_TABLE, "customer", "lc_crm_customer", null, "create table", true),
                new DdlStep(2, DdlType.ADD_COLUMN, "customer", "lc_crm_customer", "level", "alter table add column", true)));

    RollbackPrecheckReport report = service.inspect(plan);

    assertThat(report.blocked()).isFalse();
    assertThat(report.metadataRollbackSupported()).isTrue();
    assertThat(report.physicalRollbackAutoSupported()).isFalse();
    assertThat(report.physicalBoundary()).contains("需要人工 DDL 清理");
  }

  @Test
  void inspect_变更列类型和删列风险_直接阻断回滚() {
    DdlPlan plan =
        new DdlPlan(
            1L,
            10L,
            List.of(
                new DdlStep(1, DdlType.BLOCKED_CHANGE_TYPE, "customer", "lc_crm_customer", "level", "", false),
                new DdlStep(2, DdlType.BLOCKED_DROP_COLUMN, "customer", "lc_crm_customer", "mobile", "", false)));

    RollbackPrecheckReport report = service.inspect(plan);

    assertThat(report.blocked()).isTrue();
    assertThat(report.blockingRisks()).extracting(RollbackRisk::code)
        .contains("LC-META-ROLLBACK-002", "LC-META-ROLLBACK-003");
  }
}
