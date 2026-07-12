package com.lowcode.metamodel.domain.service;

/**
 * M0 状态流转草稿。
 *
 * <p>这里只描述状态图结构，不执行动作、不修改运行态数据。真正的动作执行和权限检查属于 M1。
 */
public record MetaTransitionDef(String actionCode, String fromState, String toState) {}
