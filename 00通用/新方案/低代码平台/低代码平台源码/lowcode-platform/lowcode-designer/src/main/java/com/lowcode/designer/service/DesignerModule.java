package com.lowcode.designer.service;

import org.springframework.stereotype.Component;

/**
 * 设计期模块标记。
 *
 * <p>保留这个类型是为了维持模块职责边界，同时让 Spring 能明确扫描到 designer 模块已具备运行中的服务实现。
 */
@Component
public final class DesignerModule {}
