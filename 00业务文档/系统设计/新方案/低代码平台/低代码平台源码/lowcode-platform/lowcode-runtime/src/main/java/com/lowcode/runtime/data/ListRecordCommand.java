package com.lowcode.runtime.data;

import java.util.List;
import java.util.Set;

/**
 * 动态列表查询命令。
 */
public record ListRecordCommand(Set<String> fields, List<Filter> filters, List<Sort> sorts, int pageNo, int pageSize) {}
