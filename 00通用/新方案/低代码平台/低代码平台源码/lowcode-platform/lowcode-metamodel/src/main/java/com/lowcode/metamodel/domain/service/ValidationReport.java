package com.lowcode.metamodel.domain.service;

import java.util.List;

/**
 * 元模型校验报告。
 *
 * <p>草稿保存和发布前全图校验都用同一个报告形态；区别由调用入口决定。
 */
public record ValidationReport(List<ValidationError> errors) {

  public ValidationReport {
    errors = List.copyOf(errors);
  }

  public boolean passed() {
    return errors.isEmpty();
  }
}
