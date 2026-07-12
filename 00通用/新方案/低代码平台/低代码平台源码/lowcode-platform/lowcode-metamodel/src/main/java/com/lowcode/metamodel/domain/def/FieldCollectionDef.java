package com.lowcode.metamodel.domain.def;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * 作为单个 JSON 聚合保存的带版本字段集合。
 *
 * <p>M0 刻意把字段整体作为聚合保存，用于保留草稿编辑的原子性，并支撑 T-003 的整对象乐观锁。
 */
public record FieldCollectionDef(@JsonProperty("_v") int schemaVersion, List<FieldDef> items)
    implements VersionedJson {}
