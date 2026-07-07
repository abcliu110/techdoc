package com.lowcode.metamodel.domain.schema;

/**
 * M0 DDL 计划类型。
 */
public enum DdlType {
  CREATE_TABLE,
  ADD_COLUMN,
  ADD_INDEX,
  BLOCKED_DROP_COLUMN,
  BLOCKED_NARROW_COLUMN,
  BLOCKED_CHANGE_TYPE,
  BLOCKED_UNSUPPORTED_FIELD_TYPE
}
