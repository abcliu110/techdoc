package com.lowcode.metamodel.domain.schema;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

/**
 * Schema Sync 内存执行器。
 *
 * <p>它只验证 T-004 的执行顺序、失败停顿和日志语义，不直接执行数据库 DDL。
 */
public class SchemaSyncExecutor {

  private final Predicate<DdlStep> failureInjector;
  private final List<DdlExecutionLog> logs = new ArrayList<>();

  public SchemaSyncExecutor() {
    this(step -> false);
  }

  public SchemaSyncExecutor(Predicate<DdlStep> failureInjector) {
    this.failureInjector = failureInjector;
  }

  public DdlExecutionReport execute(DdlPlan plan) {
    logs.clear();
    for (DdlStep step : plan.steps()) {
      if (!step.executable()) {
        logs.add(new DdlExecutionLog(step.stepNo(), step.type(), "blocked", "LC-META-DDL-BLOCKED", "DDL 步骤不可执行"));
        return new DdlExecutionReport(false, step.stepNo(), logs);
      }
      if (failureInjector.test(step)) {
        logs.add(new DdlExecutionLog(step.stepNo(), step.type(), "failed", "LC-META-DDL-FAILED", "DDL 执行失败"));
        return new DdlExecutionReport(false, step.stepNo(), logs);
      }
      logs.add(new DdlExecutionLog(step.stepNo(), step.type(), "success", null, null));
    }
    return new DdlExecutionReport(true, 0, logs);
  }

  public List<DdlExecutionLog> logs() {
    return List.copyOf(logs);
  }
}
