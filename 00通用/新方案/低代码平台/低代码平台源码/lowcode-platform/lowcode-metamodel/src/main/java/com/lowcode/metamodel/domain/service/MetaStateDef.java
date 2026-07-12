package com.lowcode.metamodel.domain.service;

import java.util.List;

/**
 * M0 状态草稿。
 *
 * <p>状态机在 T-003 只做结构校验：唯一初始状态、流转起止状态存在、终态标记可被快照承载。
 */
public record MetaStateDef(String code, boolean initial, boolean terminal, List<MetaTransitionDef> transitions) {

  public MetaStateDef {
    transitions = transitions == null ? List.of() : List.copyOf(transitions);
  }
}
