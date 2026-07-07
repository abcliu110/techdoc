package com.lowcode.expression.service;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * M1 表达式门面契约与安全实现。
 *
 * <p>当前实现只覆盖 expr-v1 的受控子集：字段比较、逻辑与、字符串相等和 isEmpty。它的目标不是做通用脚本引擎，
 * 而是在不引入额外依赖的前提下先固定表达式模块边界、安全白名单和权限裁剪语义。
 */
interface ExpressionService {

  ExpressionCompileResult compile(ExpressionCompileCommand command);

  ExpressionEvalResult eval(ExpressionEvalCommand command);

  ExpressionDependencyGraph analyzeDependencies(ExpressionCompileCommand command);
}

record ExpressionCompileCommand(
    String expressionText,
    ExpressionUsage usage,
    String expressionVersion,
    Set<String> allowedVariables,
    Set<String> allowedFunctions) {}

record ExpressionEvalCommand(
    String expressionText,
    ExpressionUsage usage,
    String expressionVersion,
    Map<String, Object> context,
    Set<String> allowedVariables,
    Set<String> allowedFunctions,
    long timeoutMs) {}

record ExpressionCompileResult(String expressionVersion, Set<String> fieldDependencies) {}

record ExpressionEvalResult(Object value) {}

record ExpressionDependencyGraph(Set<String> fieldDependencies) {

  /**
   * 校验公式字段依赖图是否存在自环或递归环。
   */
  void assertNoCycle(String fieldCode, Map<String, Set<String>> dependencyMap) {
    visit(fieldCode, fieldCode, dependencyMap, new HashSet<>());
  }

  private void visit(String root, String current, Map<String, Set<String>> dependencyMap, Set<String> seen) {
    if (!seen.add(current)) {
      throw new ExpressionException(ExpressionErrorCode.EXPR_DEPENDENCY_CYCLE, "表达式依赖存在循环");
    }
    for (String next : dependencyMap.getOrDefault(current, Set.of())) {
      if (Objects.equals(root, next)) {
        throw new ExpressionException(ExpressionErrorCode.EXPR_DEPENDENCY_CYCLE, "表达式依赖存在循环");
      }
      visit(root, next, dependencyMap, seen);
    }
    seen.remove(current);
  }
}

enum ExpressionUsage {
  DEFAULT,
  VISIBLE,
  READONLY,
  VALIDATE,
  DATA_SCOPE,
  TRANSITION,
  RULE,
  FORMULA
}

enum ExpressionErrorCode {
  EXPR_SYNTAX_ERROR,
  EXPR_UNSUPPORTED_FUNCTION,
  EXPR_FORBIDDEN_VARIABLE,
  EXPR_TIMEOUT,
  EXPR_CONTEXT_TOO_LARGE,
  EXPR_TYPE_MISMATCH,
  EXPR_PERMISSION_DENIED,
  EXPR_DEPENDENCY_CYCLE,
  EXPR_VERSION_UNSUPPORTED
}

class ExpressionException extends RuntimeException {

  private final ExpressionErrorCode errorCode;

  ExpressionException(ExpressionErrorCode errorCode, String message) {
    super(message);
    this.errorCode = errorCode;
  }

  public ExpressionErrorCode getErrorCode() {
    return errorCode;
  }
}

class SafeExpressionService implements ExpressionService {

  private static final Pattern FIELD_PATTERN = Pattern.compile("\\brecord\\.([A-Za-z][A-Za-z0-9_]*)\\b");
  private static final Set<String> FORBIDDEN_TOKENS = Set.of(
      "T(", "java.", "javax.", "Runtime", "System", "Class", "class", "exec", "getenv", "File", "Socket");

  @Override
  public ExpressionCompileResult compile(ExpressionCompileCommand command) {
    validateVersion(command.expressionVersion());
    rejectForbiddenTokens(command.expressionText());
    Set<String> dependencies = extractFieldDependencies(command.expressionText());
    ensureVariablesAllowed(dependencies, command.allowedVariables());
    ensureFunctionsAllowed(command.expressionText(), command.allowedFunctions());
    return new ExpressionCompileResult(command.expressionVersion(), dependencies);
  }

  @Override
  public ExpressionEvalResult eval(ExpressionEvalCommand command) {
    long started = System.nanoTime();
    compile(new ExpressionCompileCommand(
        command.expressionText(),
        command.usage(),
        command.expressionVersion(),
        command.allowedVariables(),
        command.allowedFunctions()));
    Object value = evaluateAndExpression(command.expressionText(), command.context());
    long elapsedMs = (System.nanoTime() - started) / 1_000_000;
    if (elapsedMs > command.timeoutMs()) {
      throw new ExpressionException(ExpressionErrorCode.EXPR_TIMEOUT, "表达式执行超时");
    }
    return new ExpressionEvalResult(value);
  }

  @Override
  public ExpressionDependencyGraph analyzeDependencies(ExpressionCompileCommand command) {
    ExpressionCompileResult result = compile(command);
    return new ExpressionDependencyGraph(result.fieldDependencies());
  }

  private static Object evaluateAndExpression(String expressionText, Map<String, Object> context) {
    String[] parts = expressionText.split("\\s+&&\\s+");
    boolean result = true;
    for (String part : parts) {
      result = result && evaluateCondition(part.trim(), context);
    }
    return result;
  }

  @SuppressWarnings("unchecked")
  private static boolean evaluateCondition(String part, Map<String, Object> context) {
    if (part.startsWith("isEmpty(") && part.endsWith(")")) {
      Object value = resolveValue(part.substring("isEmpty(".length(), part.length() - 1), context);
      return value == null || value.toString().isEmpty();
    }
    if (part.contains(" > ")) {
      String[] pieces = part.split("\\s+>\\s+");
      return toDecimal(resolveValue(pieces[0], context)).compareTo(new BigDecimal(pieces[1])) > 0;
    }
    if (part.contains(" == ")) {
      String[] pieces = part.split("\\s+==\\s+");
      Object left = resolveValue(pieces[0], context);
      String right = pieces[1].replace("'", "").replace("\"", "");
      return Objects.equals(String.valueOf(left), right);
    }
    if (context.get("record") instanceof Map<?, ?> record) {
      return Boolean.TRUE.equals(((Map<String, Object>) record).get(part));
    }
    throw new ExpressionException(ExpressionErrorCode.EXPR_SYNTAX_ERROR, "不支持的表达式片段");
  }

  @SuppressWarnings("unchecked")
  private static Object resolveValue(String token, Map<String, Object> context) {
    String normalized = token.trim();
    if (normalized.startsWith("record.")) {
      Object record = context.get("record");
      if (!(record instanceof Map<?, ?> map)) {
        return null;
      }
      return ((Map<String, Object>) map).get(normalized.substring("record.".length()));
    }
    if (normalized.matches("[A-Za-z][A-Za-z0-9_]*") && context.get("record") instanceof Map<?, ?> map) {
      return ((Map<String, Object>) map).get(normalized);
    }
    return normalized;
  }

  private static BigDecimal toDecimal(Object value) {
    if (value instanceof BigDecimal decimal) {
      return decimal;
    }
    if (value instanceof Number number) {
      return BigDecimal.valueOf(number.doubleValue());
    }
    return new BigDecimal(String.valueOf(value));
  }

  private static void validateVersion(String expressionVersion) {
    if (!"expr-v1".equals(expressionVersion)) {
      throw new ExpressionException(ExpressionErrorCode.EXPR_VERSION_UNSUPPORTED, "不支持的表达式版本");
    }
  }

  private static void rejectForbiddenTokens(String expressionText) {
    for (String token : FORBIDDEN_TOKENS) {
      if (expressionText.contains(token)) {
        throw new ExpressionException(ExpressionErrorCode.EXPR_FORBIDDEN_VARIABLE, "表达式包含禁止访问入口");
      }
    }
  }

  private static void ensureVariablesAllowed(Set<String> dependencies, Set<String> allowedVariables) {
    for (String dependency : dependencies) {
      if (!allowedVariables.contains("record." + dependency)) {
        throw new ExpressionException(ExpressionErrorCode.EXPR_PERMISSION_DENIED, "表达式依赖无权限字段");
      }
    }
  }

  private static void ensureFunctionsAllowed(String expressionText, Set<String> allowedFunctions) {
    Matcher matcher = Pattern.compile("\\b([A-Za-z][A-Za-z0-9_]*)\\s*\\(").matcher(expressionText);
    while (matcher.find()) {
      String function = matcher.group(1);
      if (!allowedFunctions.contains(function)) {
        throw new ExpressionException(ExpressionErrorCode.EXPR_UNSUPPORTED_FUNCTION, "表达式函数未在白名单内");
      }
    }
  }

  private static Set<String> extractFieldDependencies(String expressionText) {
    Matcher matcher = FIELD_PATTERN.matcher(expressionText);
    Set<String> result = new HashSet<>();
    while (matcher.find()) {
      result.add(matcher.group(1));
    }
    return result;
  }
}
