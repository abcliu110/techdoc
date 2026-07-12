package com.lowcode.metamodel.domain.def;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 字段选项结构。
 *
 * <p>M0 只放 Schema Sync 和结构校验已经需要的公共选项。字段类型继续通过 `fieldType` 决定如何消费这些选项，
 * 但选项 DTO 本身不承载运行时行为，避免把后续执行能力提前带进元模型层。
 */
public record FieldOptionsDef(
    @JsonProperty("_v") int schemaVersion,
    Integer length,
    Integer precision,
    Integer scale,
    String targetObjectCode,
    String throughObjectCode,
    String fetchFrom,
    Boolean inFilter,
    Boolean persisted)
    implements VersionedJson {

  public FieldOptionsDef(@JsonProperty("_v") int schemaVersion) {
    this(schemaVersion, null, null, null, null, null, null, null, null);
  }

  public static FieldOptionsDef text(int schemaVersion, int length) {
    return new FieldOptionsDef(schemaVersion, length, null, null, null, null, null, null, null);
  }

  public static FieldOptionsDef decimal(int schemaVersion, int precision, int scale) {
    return new FieldOptionsDef(schemaVersion, null, precision, scale, null, null, null, null, null);
  }

  public static FieldOptionsDef link(int schemaVersion, String targetObjectCode) {
    return new FieldOptionsDef(schemaVersion, null, null, null, targetObjectCode, null, null, null, null);
  }

  public static FieldOptionsDef multilink(int schemaVersion, String targetObjectCode, String throughObjectCode) {
    return new FieldOptionsDef(schemaVersion, null, null, null, targetObjectCode, throughObjectCode, null, null, null);
  }

  public static FieldOptionsDef fetchFrom(int schemaVersion, String fetchFrom) {
    return new FieldOptionsDef(schemaVersion, null, null, null, null, null, fetchFrom, null, null);
  }

  public static FieldOptionsDef multiselect(int schemaVersion, boolean inFilter) {
    return new FieldOptionsDef(schemaVersion, null, null, null, null, null, null, inFilter, null);
  }

  public static FieldOptionsDef formula(int schemaVersion, boolean persisted) {
    return new FieldOptionsDef(schemaVersion, null, null, null, null, null, null, null, persisted);
  }
}
