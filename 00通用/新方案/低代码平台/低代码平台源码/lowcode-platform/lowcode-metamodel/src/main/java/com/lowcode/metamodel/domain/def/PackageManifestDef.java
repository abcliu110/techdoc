package com.lowcode.metamodel.domain.def;

import java.util.List;

/** 应用包占位结构。M0 禁止安装或执行应用包。 */
public record PackageManifestDef(
    String packageCode,
    String version,
    List<PackageDependencyDef> dependencies,
    String license,
    List<String> objects,
    List<String> extensions,
    List<String> menus,
    List<String> reports,
    List<String> permissions,
    PackageCompatibilityDef compatibility,
    boolean runtimeEnabled) {

  public PackageManifestDef {
    dependencies = dependencies == null ? List.of() : List.copyOf(dependencies);
    objects = objects == null ? List.of() : List.copyOf(objects);
    extensions = extensions == null ? List.of() : List.copyOf(extensions);
    menus = menus == null ? List.of() : List.copyOf(menus);
    reports = reports == null ? List.of() : List.copyOf(reports);
    permissions = permissions == null ? List.of() : List.copyOf(permissions);
  }

  public PackageManifestDef(String packageCode, String version, boolean runtimeEnabled) {
    this(packageCode, version, List.of(), null, List.of(), List.of(), List.of(), List.of(), List.of(), null, runtimeEnabled);
  }
}
