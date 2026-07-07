package com.lowcode.expression.service;

/**
 * 表达式门面模块标记。
 *
 * <p>M0 刻意不引入表达式引擎。这个边界用于保证后续代码只有一个经过批准的位置来集成沙箱求值。
 */
public final class ExpressionModule {

  private ExpressionModule() {}
}
