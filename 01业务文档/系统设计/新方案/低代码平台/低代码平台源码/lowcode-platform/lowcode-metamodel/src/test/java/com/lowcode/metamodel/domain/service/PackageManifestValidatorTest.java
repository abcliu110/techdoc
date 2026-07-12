package com.lowcode.metamodel.domain.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.PackageCompatibilityDef;
import com.lowcode.metamodel.domain.def.PackageDependencyDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class PackageManifestValidatorTest {

  private final PackageManifestValidator validator = new PackageManifestValidator();

  @Test
  void validate_缺依赖和缺兼容声明_返回阻断错误() {
    PackageManifestDef manifest =
        new PackageManifestDef(
            "sales_pkg",
            "1.2.0",
            List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
            "Commercial",
            List.of("customer"),
            List.of("customer_ext"),
            List.of("sales_menu"),
            List.of("sales_report"),
            List.of("report.view"),
            null,
            true);

    ValidationReport report =
        validator.validate(
            manifest,
            new PackageManifestValidationContext(
                Map.of(),
                Set.of("customer"),
                Set.of("customer_ext"),
                Set.of("sales_menu"),
                Set.of("sales_report"),
                Set.of("report.view"),
                "1.0.0",
                "stable-1",
                Set.of("Commercial"),
                true));

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).extracting(ValidationError::code)
        .contains("LC-META-PKG-001", "LC-META-PKG-006");
  }

  @Test
  void validate_完整清单_通过校验() {
    PackageManifestDef manifest =
        new PackageManifestDef(
            "sales_pkg",
            "1.2.0",
            List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
            "Commercial",
            List.of("customer"),
            List.of("customer_ext"),
            List.of("sales_menu"),
            List.of("sales_report"),
            List.of("report.view"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "stable-1"),
            true);

    ValidationReport report =
        validator.validate(
            manifest,
            new PackageManifestValidationContext(
                Map.of("base_pkg", "1.0.1"),
                Set.of("customer"),
                Set.of("customer_ext"),
                Set.of("sales_menu"),
                Set.of("sales_report"),
                Set.of("report.view"),
                "1.0.0",
                "stable-1",
                Set.of("Commercial"),
                true));

    assertThat(report.passed()).isTrue();
  }

  @Test
  void validate_缺License时返回校验错误而不是抛异常() {
    PackageManifestDef manifest =
        new PackageManifestDef(
            "sales_pkg",
            "1.2.0",
            List.of(),
            null,
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "stable-1"),
            true);

    ValidationReport report =
        validator.validate(
            manifest,
            new PackageManifestValidationContext(
                Map.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                "1.0.0",
                "stable-1",
                Set.of("Commercial"),
                true));

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).extracting(ValidationError::code).contains("LC-META-PKG-004");
  }

  @Test
  void validate_依赖版本License和运行态约束不满足_返回阻断错误() {
    PackageManifestDef manifest =
        new PackageManifestDef(
            "sales_pkg",
            "2.0.0",
            List.of(new PackageDependencyDef("base_pkg", "2.0.0")),
            "Enterprise",
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            new PackageCompatibilityDef("2.0.0", "2.1.x", "M5"),
            true);

    ValidationReport report =
        validator.validate(
            manifest,
            new PackageManifestValidationContext(
                Map.of("base_pkg", "1.0.1"),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                "1.0.0",
                "M4",
                Set.of("Commercial"),
                false));

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).extracting(ValidationError::code)
        .contains("LC-META-PKG-012", "LC-META-PKG-013", "LC-META-PKG-014", "LC-META-PKG-015");
  }
}
