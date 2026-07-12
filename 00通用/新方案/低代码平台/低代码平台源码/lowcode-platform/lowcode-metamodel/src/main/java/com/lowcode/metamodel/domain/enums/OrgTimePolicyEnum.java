package com.lowcode.metamodel.domain.enums;

/** 组织关系元数据的时间语义。 */
public enum OrgTimePolicyEnum implements CodeEnum {
  OWNER_SNAPSHOT("owner_snapshot"),
  CURRENT_ORG("current_org");

  private final String code;

  OrgTimePolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
