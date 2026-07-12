package com.lowcode.runtime.data;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 动态对象运行态定义。
 */
public record DynamicObjectDefinition(
    String objectCode,
    String tableName,
    Map<String, FieldDefinition> fields,
    StateMachineDefinition stateMachine) {

  public static Builder builder(String objectCode, String tableName) {
    return new Builder(objectCode, tableName);
  }

  public static final class Builder {
    private final String objectCode;
    private final String tableName;
    private final Map<String, FieldDefinition> fields = new LinkedHashMap<>();
    private StateMachineDefinition stateMachine;

    private Builder(String objectCode, String tableName) {
      this.objectCode = objectCode;
      this.tableName = tableName;
    }

    public Builder field(String code, FieldKind kind) {
      fields.put(code, new FieldDefinition(code, kind));
      return this;
    }

    public Builder stateMachine(StateMachineDefinition stateMachine) {
      this.stateMachine = stateMachine;
      return this;
    }

    public DynamicObjectDefinition build() {
      // 动态 SQL 的列序必须稳定，避免审计、测试和数据库计划在不同 JVM 运行中漂移。
      return new DynamicObjectDefinition(objectCode, tableName, Collections.unmodifiableMap(new LinkedHashMap<>(fields)), stateMachine);
    }
  }
}
