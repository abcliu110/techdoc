package com.lowcode.app.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.graph.InMemoryMetaVersionPointer;
import com.lowcode.metamodel.domain.graph.InMemoryMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaGraphProvider;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import com.lowcode.runtime.api.RuntimeApiFacade;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class PublishedRuntimeObjectRegistryTest {

  @Test
  void shouldRegisterRuntimeObjectFromPublishedMetaGraph() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    repository.save(snapshot());
    pointer.setCurrent(3L, "sales", "mh-1");
    RuntimeApiFacade runtimeApiFacade = new RuntimeApiFacade();
    PublishedRuntimeObjectRegistry registry = new PublishedRuntimeObjectRegistry(
        runtimeApiFacade,
        new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3));
    AuthenticatedRuntimeContext context = new AuthenticatedRuntimeContext(
        3L,
        70L,
        "manager-1",
        Set.of("manager"),
        "sales",
        "invoice",
        "mh-1",
        "trace-registry");

    registry.ensureRegistered(context);
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiFacade, registry);
    AddRecordResponse response = facade.add(context, new AddRecordRequest(
        "mh-1",
        "registry-add",
        Map.of("total", "99.50", "title", "from graph")));

    assertThat(response.revision()).isEqualTo(1);
    assertThat(facade.meta(context).fields()).containsExactlyInAnyOrder("total", "title");
    assertThat(facade.get(context, new RecordReadRequest(response.recordLid(), Set.of("total", "title"))))
        .containsEntry("total", new java.math.BigDecimal("99.50"))
        .containsEntry("title", "from graph");
  }

  @Test
  void shouldRegisterAllRuntimeSupportedPublishedFieldTypes() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    repository.save(snapshotWithAllRuntimeSupportedTypes());
    pointer.setCurrent(3L, "sales", "mh-all");
    RuntimeApiFacade runtimeApiFacade = new RuntimeApiFacade();
    PublishedRuntimeObjectRegistry registry = new PublishedRuntimeObjectRegistry(
        runtimeApiFacade,
        new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3));
    AuthenticatedRuntimeContext context = new AuthenticatedRuntimeContext(
        3L,
        70L,
        "manager-1",
        Set.of("manager"),
        "sales",
        "all_fields",
        "mh-all",
        "trace-registry-all");

    registry.ensureRegistered(context);
    RuntimeHttpFacade facade = new RuntimeApiHttpFacade(runtimeApiFacade, registry);
    AddRecordResponse response = facade.add(context, new AddRecordRequest(
        "mh-all",
        "registry-all-add",
        Map.of(
            "text_value", "hello",
            "integer_value", "12",
            "decimal_value", "99.50",
            "checkbox_value", true,
            "date_value", "2026-07-07",
            "select_value", "A",
            "link_value", "01LINKTARGET00000000000000",
            "attachment_value", "[\"att-1\"]")));

    assertThat(facade.meta(context).fields()).containsExactlyInAnyOrder(
        "text_value",
        "textarea_value",
        "richtext_value",
        "code_value",
        "integer_value",
        "decimal_value",
        "percent_value",
        "currency_value",
        "date_value",
        "datetime_value",
        "time_value",
        "select_value",
        "multiselect_value",
        "checkbox_value",
        "link_value",
        "autonumber_value",
        "user_value",
        "org_value",
        "attachment_value");
    assertThat(facade.get(context, new RecordReadRequest(response.recordLid(), Set.of("integer_value", "decimal_value", "checkbox_value"))))
        .containsEntry("integer_value", 12L)
        .containsEntry("decimal_value", new java.math.BigDecimal("99.50"))
        .containsEntry("checkbox_value", true);
  }

  private static AppSnapshotDef snapshot() {
    MetaObjectDraft invoice = new MetaObjectDraft(
        3L,
        10L,
        "invoice",
        "发票",
        ObjectTypeEnum.DOCUMENT,
        List.of(
            new FieldDef("total", "金额", FieldTypeEnum.DECIMAL, true, FieldOptionsDef.decimal(1, 18, 2)),
            new FieldDef("title", "标题", FieldTypeEnum.TEXT, false, FieldOptionsDef.text(1, 128))));
    return new AppSnapshotDef(
        1,
        3L,
        "sales",
        "mh-1",
        List.of(invoice),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        CommercialMetadataDef.empty(1));
  }

  private static AppSnapshotDef snapshotWithAllRuntimeSupportedTypes() {
    MetaObjectDraft object = new MetaObjectDraft(
        3L,
        10L,
        "all_fields",
        "All Fields",
        ObjectTypeEnum.DOCUMENT,
        List.of(
            new FieldDef("text_value", "Text", FieldTypeEnum.TEXT, false, FieldOptionsDef.text(1, 128)),
            new FieldDef("textarea_value", "Textarea", FieldTypeEnum.TEXTAREA, false, FieldOptionsDef.text(1, 1024)),
            new FieldDef("richtext_value", "Richtext", FieldTypeEnum.RICHTEXT, false, new FieldOptionsDef(1)),
            new FieldDef("code_value", "Code", FieldTypeEnum.CODE, false, new FieldOptionsDef(1)),
            new FieldDef("integer_value", "Integer", FieldTypeEnum.INTEGER, false, new FieldOptionsDef(1)),
            new FieldDef("decimal_value", "Decimal", FieldTypeEnum.DECIMAL, false, FieldOptionsDef.decimal(1, 18, 2)),
            new FieldDef("percent_value", "Percent", FieldTypeEnum.PERCENT, false, FieldOptionsDef.decimal(1, 9, 4)),
            new FieldDef("currency_value", "Currency", FieldTypeEnum.CURRENCY, false, FieldOptionsDef.decimal(1, 18, 4)),
            new FieldDef("date_value", "Date", FieldTypeEnum.DATE, false, new FieldOptionsDef(1)),
            new FieldDef("datetime_value", "Datetime", FieldTypeEnum.DATETIME, false, new FieldOptionsDef(1)),
            new FieldDef("time_value", "Time", FieldTypeEnum.TIME, false, new FieldOptionsDef(1)),
            new FieldDef("select_value", "Select", FieldTypeEnum.SELECT, false, new FieldOptionsDef(1)),
            new FieldDef("multiselect_value", "Multiselect", FieldTypeEnum.MULTISELECT, false, FieldOptionsDef.multiselect(1, false)),
            new FieldDef("checkbox_value", "Checkbox", FieldTypeEnum.CHECKBOX, false, new FieldOptionsDef(1)),
            new FieldDef("link_value", "Link", FieldTypeEnum.LINK, false, FieldOptionsDef.link(1, "customer")),
            new FieldDef("autonumber_value", "Autonumber", FieldTypeEnum.AUTONUMBER, false, new FieldOptionsDef(1)),
            new FieldDef("user_value", "User", FieldTypeEnum.USER, false, new FieldOptionsDef(1)),
            new FieldDef("org_value", "Org", FieldTypeEnum.ORG, false, new FieldOptionsDef(1)),
            new FieldDef("attachment_value", "Attachment", FieldTypeEnum.ATTACHMENT, false, new FieldOptionsDef(1)),
            new FieldDef("table_value", "Table", FieldTypeEnum.TABLE, false, FieldOptionsDef.link(1, "line")),
            new FieldDef("multilink_value", "Multilink", FieldTypeEnum.MULTILINK, false, FieldOptionsDef.multilink(1, "tag", "all_tag")),
            new FieldDef("formula_value", "Formula", FieldTypeEnum.FORMULA, false, FieldOptionsDef.formula(1, false))));
    return new AppSnapshotDef(
        1,
        3L,
        "sales",
        "mh-all",
        List.of(object),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        CommercialMetadataDef.empty(1));
  }
}
