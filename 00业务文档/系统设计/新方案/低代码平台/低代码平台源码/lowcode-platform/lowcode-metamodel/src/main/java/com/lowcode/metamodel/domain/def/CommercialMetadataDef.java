package com.lowcode.metamodel.domain.def;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Collections;
import java.util.List;

/**
 * 商业平台元数据的 M0 承载结构。
 *
 * <p>这个聚合用于证明 REQ-070 到 REQ-078 可以被结构化表达，同时不假装运行时已经存在。
 * T-003 的校验器会拒绝这些结构上的任何 runtime-enabled 标记。
 */
public record CommercialMetadataDef(
    @JsonProperty("_v") int schemaVersion,
    List<ObjectExtensionDef> objectExtensions,
    List<LinkConfigDef> linkConfigs,
    List<ConversionDef> conversions,
    List<WriteBackDef> writeBacks,
    List<LinkTraceDef> linkTraces,
    List<FlexFieldDef> flexFields,
    List<OrgRelationDef> orgRelations,
    List<CodeRuleDef> codeRules,
    List<ReportDef> reports,
    List<PrintTemplateDef> printTemplates,
    List<MenuDef> menus,
    List<I18nResourceDef> i18nResources,
    List<PackageManifestDef> packageManifests,
    List<LicensePolicyDef> licensePolicies)
    implements VersionedJson {

  public CommercialMetadataDef(
      int schemaVersion,
      List<ObjectExtensionDef> objectExtensions,
      List<ConversionDef> conversions,
      List<LicensePolicyDef> licensePolicies) {
    this(
        schemaVersion,
        objectExtensions,
        List.of(),
        conversions,
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        licensePolicies);
  }

  public static CommercialMetadataDef empty(int schemaVersion) {
    return new CommercialMetadataDef(
        schemaVersion,
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        List.of());
  }

  public CommercialMetadataDef {
    objectExtensions = immutable(objectExtensions);
    linkConfigs = immutable(linkConfigs);
    conversions = immutable(conversions);
    writeBacks = immutable(writeBacks);
    linkTraces = immutable(linkTraces);
    flexFields = immutable(flexFields);
    orgRelations = immutable(orgRelations);
    codeRules = immutable(codeRules);
    reports = immutable(reports);
    printTemplates = immutable(printTemplates);
    menus = immutable(menus);
    i18nResources = immutable(i18nResources);
    packageManifests = immutable(packageManifests);
    licensePolicies = immutable(licensePolicies);
  }

  public CommercialMetadataDef withObjectExtensions(List<ObjectExtensionDef> value) {
    return copy(value, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withLinkConfigs(List<LinkConfigDef> value) {
    return copy(objectExtensions, value, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withConversions(List<ConversionDef> value) {
    return copy(objectExtensions, linkConfigs, value, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withWriteBacks(List<WriteBackDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, value, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withLinkTraces(List<LinkTraceDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, value, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withFlexFields(List<FlexFieldDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, value, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withOrgRelations(List<OrgRelationDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, value,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withCodeRules(List<CodeRuleDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        value, reports, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withReports(List<ReportDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, value, printTemplates, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withPrintTemplates(List<PrintTemplateDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, value, menus, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withMenus(List<MenuDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, value, i18nResources, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withI18nResources(List<I18nResourceDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, value, packageManifests, licensePolicies);
  }

  public CommercialMetadataDef withPackageManifests(List<PackageManifestDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, value, licensePolicies);
  }

  public CommercialMetadataDef withLicensePolicies(List<LicensePolicyDef> value) {
    return copy(objectExtensions, linkConfigs, conversions, writeBacks, linkTraces, flexFields, orgRelations,
        codeRules, reports, printTemplates, menus, i18nResources, packageManifests, value);
  }

  private CommercialMetadataDef copy(
      List<ObjectExtensionDef> objectExtensions,
      List<LinkConfigDef> linkConfigs,
      List<ConversionDef> conversions,
      List<WriteBackDef> writeBacks,
      List<LinkTraceDef> linkTraces,
      List<FlexFieldDef> flexFields,
      List<OrgRelationDef> orgRelations,
      List<CodeRuleDef> codeRules,
      List<ReportDef> reports,
      List<PrintTemplateDef> printTemplates,
      List<MenuDef> menus,
      List<I18nResourceDef> i18nResources,
      List<PackageManifestDef> packageManifests,
      List<LicensePolicyDef> licensePolicies) {
    return new CommercialMetadataDef(
        schemaVersion,
        objectExtensions,
        linkConfigs,
        conversions,
        writeBacks,
        linkTraces,
        flexFields,
        orgRelations,
        codeRules,
        reports,
        printTemplates,
        menus,
        i18nResources,
        packageManifests,
        licensePolicies);
  }

  private static <T> List<T> immutable(List<T> value) {
    return value == null ? List.of() : Collections.unmodifiableList(value);
  }
}
