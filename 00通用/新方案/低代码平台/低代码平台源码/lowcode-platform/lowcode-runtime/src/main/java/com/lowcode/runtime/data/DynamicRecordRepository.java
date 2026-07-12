package com.lowcode.runtime.data;

import java.util.List;

/**
 * 动态业务记录仓储边界。
 *
 * <p>运行态写入管线只依赖该接口，方便在内存特征化测试和 JDBC/MySQL 持久化实现之间切换。接口参数始终携带
 * {@link DynamicObjectDefinition} 与 {@link RuntimeExecutionContext}，避免仓储层脱离元数据白名单和租户上下文自行查询。
 */
public interface DynamicRecordRepository {

  void insert(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record);

  List<DynamicRecord> list(
      DynamicObjectDefinition definition,
      RuntimeExecutionContext context,
      List<Filter> filters,
      List<Sort> sorts,
      int pageNo,
      int pageSize);

  DynamicRecord require(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid);

  void update(DynamicObjectDefinition definition, RuntimeExecutionContext context, DynamicRecord record);

  void softDelete(DynamicObjectDefinition definition, RuntimeExecutionContext context, String recordLid, Long revision);
}
