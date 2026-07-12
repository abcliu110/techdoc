package com.lowcode.metamodel.domain;

/**
 * 元模型模块边界标记。
 *
 * <p>真实 M0 行为从 T-002 开始。保留这个标记类，是为了在实体、服务和 Schema Sync 代码出现前，
 * 架构测试也能稳定导入本模块。
 */
public final class MetamodelModule {

  private MetamodelModule() {}
}
