package com.lowcode.metamodel.domain.schema;

import java.util.List;

/**
 * Schema Sync 的 DDL 计划。
 *
 * <p>M0 必须先生成计划再执行；当前类只表达计划结果，不负责真实执行数据库 DDL。
 */
public record DdlPlan(Long tenantId, Long appId, List<DdlStep> steps) {

  public DdlPlan {
    steps = List.copyOf(steps);
  }

  public boolean executable() {
    return steps.stream().allMatch(DdlStep::executable);
  }
}
