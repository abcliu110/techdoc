package com.lowcode.metamodel.domain.def;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * 已发布应用快照载体。
 *
 * <p>T-005 会基于这个结构构建 MetaGraph。T-002 只冻结 JSON 外壳，让后续服务可以依赖带版本的快照契约。
 */
public record AppSnapshotDef(
    @JsonProperty("_v") int schemaVersion,
    Long tenantId,
    String appCode,
    String versionNo,
    List<Object> objects,
    List<Object> pages,
    List<Object> roles,
    List<Object> datasources,
    List<Object> plugins,
    CommercialMetadataDef commercial)
    implements VersionedJson {}
