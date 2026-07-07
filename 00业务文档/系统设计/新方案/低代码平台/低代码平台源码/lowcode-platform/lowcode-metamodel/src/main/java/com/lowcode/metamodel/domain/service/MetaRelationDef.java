package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.enums.RelationTypeEnum;

/**
 * 字段视角同步出来的模型关系。
 *
 * <p>M0 只保存关系事实，运行时 join、权限裁剪和 through 表执行能力留给后续任务。
 */
public record MetaRelationDef(String sourceObjectCode, String sourceFieldCode, String targetObjectCode, RelationTypeEnum relationType) {}
