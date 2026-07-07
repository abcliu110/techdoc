package com.lowcode.expression.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class ExpressionServiceTest {

  private final ExpressionService service = new SafeExpressionService();

  @Test
  void shouldEvaluateValidateExpressionWithWhitelistedVariablesAndFunctions() {
    ExpressionEvalResult result = service.eval(new ExpressionEvalCommand(
        "amount > 10000 && isEmpty(approval_comment)",
        ExpressionUsage.VALIDATE,
        "expr-v1",
        Map.of("record", Map.of("amount", new BigDecimal("12000"), "approval_comment", "")),
        Set.of("record.amount", "record.approval_comment"),
        Set.of("isEmpty"),
        100));

    assertThat(result.value()).isEqualTo(Boolean.TRUE);
  }

  @Test
  void shouldRejectForbiddenJavaAndSystemAccess() {
    assertThatThrownBy(() -> service.compile(new ExpressionCompileCommand(
            "T(java.lang.Runtime).getRuntime().exec('calc')",
            ExpressionUsage.RULE,
            "expr-v1",
            Set.of("record.amount"),
            Set.of("isEmpty"))))
        .isInstanceOf(ExpressionException.class)
        .extracting("errorCode")
        .isEqualTo(ExpressionErrorCode.EXPR_FORBIDDEN_VARIABLE);
  }

  @Test
  void shouldRejectVariablesOutsideAccessView() {
    assertThatThrownBy(() -> service.compile(new ExpressionCompileCommand(
            "record.secret_amount > 0",
            ExpressionUsage.DATA_SCOPE,
            "expr-v1",
            Set.of("record.amount"),
            Set.of())))
        .isInstanceOf(ExpressionException.class)
        .extracting("errorCode")
        .isEqualTo(ExpressionErrorCode.EXPR_PERMISSION_DENIED);
  }

  @Test
  void shouldExtractFieldDependenciesAndDetectSelfCycle() {
    ExpressionDependencyGraph graph = service.analyzeDependencies(new ExpressionCompileCommand(
        "record.amount > 10000 && record.customer_level == 'vip'",
        ExpressionUsage.FORMULA,
        "expr-v1",
        Set.of("record.amount", "record.customer_level"),
        Set.of()));

    assertThat(graph.fieldDependencies()).containsExactlyInAnyOrder("amount", "customer_level");

    assertThatThrownBy(() -> graph.assertNoCycle("amount", Map.of("amount", Set.of("amount"))))
        .isInstanceOf(ExpressionException.class)
        .extracting("errorCode")
        .isEqualTo(ExpressionErrorCode.EXPR_DEPENDENCY_CYCLE);
  }
}
