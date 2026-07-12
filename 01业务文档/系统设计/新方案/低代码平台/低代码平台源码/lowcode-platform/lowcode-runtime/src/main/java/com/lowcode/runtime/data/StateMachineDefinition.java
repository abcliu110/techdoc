package com.lowcode.runtime.data;

import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 运行态状态机定义。
 */
public record StateMachineDefinition(String initialState, List<StateTransition> transitions) {

  public static StateMachineDefinition simpleApproval(String initialState, String approvedState, String actionCode, Set<String> allowedRoles) {
    return new StateMachineDefinition(initialState, List.of(new StateTransition(actionCode, initialState, approvedState, allowedRoles)));
  }

  StateTransition transition(String actionCode, String fromState) {
    return transitions.stream()
        .filter(item -> Objects.equals(item.actionCode(), actionCode) && Objects.equals(item.fromState(), fromState))
        .findFirst()
        .orElseThrow(() -> new RuntimeDataException(RuntimeDataErrorCode.STATE_NOT_EDITABLE, "状态流转不合法"));
  }

  public Set<String> allowedActionsFor(Set<String> roleCodes) {
    Set<String> safeRoleCodes = roleCodes == null ? Set.of() : roleCodes;
    return transitions.stream()
        .filter(item -> !java.util.Collections.disjoint(item.allowedRoles(), safeRoleCodes))
        .map(StateTransition::actionCode)
        .collect(Collectors.toUnmodifiableSet());
  }
}
