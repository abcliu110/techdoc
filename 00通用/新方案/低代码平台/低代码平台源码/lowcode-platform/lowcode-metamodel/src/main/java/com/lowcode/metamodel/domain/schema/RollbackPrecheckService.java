package com.lowcode.metamodel.domain.schema;

import java.util.ArrayList;
import java.util.List;

/** 发布回滚预检器。 */
public class RollbackPrecheckService {

  public RollbackPrecheckReport inspect(DdlPlan plan) {
    List<RollbackRisk> risks = new ArrayList<>();
    for (DdlStep step : plan.steps()) {
      if (step.type() == DdlType.BLOCKED_CHANGE_TYPE) {
        risks.add(new RollbackRisk("LC-META-ROLLBACK-002", "列类型变更不可自动回滚：" + step.columnName()));
      }
      if (step.type() == DdlType.BLOCKED_DROP_COLUMN) {
        risks.add(new RollbackRisk("LC-META-ROLLBACK-003", "删列变更不可自动回滚：" + step.columnName()));
      }
    }
    return new RollbackPrecheckReport(
        true,
        false,
        "元数据快照可回滚，物理 DDL 需要人工 DDL 清理或单独变更单处理",
        risks);
  }
}
