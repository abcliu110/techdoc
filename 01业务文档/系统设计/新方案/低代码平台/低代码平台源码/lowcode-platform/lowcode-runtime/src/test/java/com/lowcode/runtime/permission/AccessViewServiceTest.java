package com.lowcode.runtime.permission;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class AccessViewServiceTest {

  @Test
  void shouldDenyWhenNoRoleProvided() {
    AccessView view = new AccessViewService().merge("order", "mh-1", 7L);

    assertThat(view.operations()).isEmpty();
    assertThat(view.actionSet()).isEmpty();
    assertThat(view.fieldView()).isEmpty();
    assertThat(view.dataScope().scope()).isEqualTo(DataScopeType.SELF);
    assertThat(view.explain().allowed()).isFalse();
    assertThat(view.explain().reasons()).contains("角色为空，默认拒绝");
  }

  @Test
  void shouldMergeRolesWithDenyFirstAndProduceExplainableAccessView() {
    PermissionRole sales = new PermissionRole(
        "sales",
        Set.of(Operation.READ, Operation.UPDATE),
        DataScope.self(),
        Map.of(
            "amount", FieldAccess.READ,
            "secret_amount", FieldAccess.NONE,
            "remark", FieldAccess.WRITE),
        Set.of("submit"));
    PermissionRole clerk = new PermissionRole(
        "clerk",
        Set.of(Operation.READ),
        DataScope.all(),
        Map.of(
            "amount", FieldAccess.MASKED,
            "remark", FieldAccess.READ),
        Set.of());

    AccessView view = new AccessViewService().merge("order", "mh-1", 7L, sales, clerk);

    assertThat(view.can(Operation.READ)).isTrue();
    assertThat(view.can(Operation.DELETE)).isFalse();
    assertThat(view.fieldAccess("secret_amount")).isEqualTo(FieldAccess.NONE);
    assertThat(view.fieldAccess("remark")).isEqualTo(FieldAccess.WRITE);
    assertThat(view.dataScope().scope()).isEqualTo(DataScopeType.SELF);
    assertThat(view.explain().reasons()).contains("字段 secret_amount 被显式拒绝");
  }
}
