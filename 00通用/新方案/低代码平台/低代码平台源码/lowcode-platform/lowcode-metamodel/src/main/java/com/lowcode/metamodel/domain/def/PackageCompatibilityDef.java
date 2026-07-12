package com.lowcode.metamodel.domain.def;

/** 应用包兼容范围声明。 */
public record PackageCompatibilityDef(String minPlatformVersion, String maxTestedPlatformVersion, String apiLevel) {}
