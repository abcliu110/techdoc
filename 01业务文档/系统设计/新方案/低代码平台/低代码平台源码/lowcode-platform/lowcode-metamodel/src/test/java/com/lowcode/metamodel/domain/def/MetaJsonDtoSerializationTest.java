package com.lowcode.metamodel.domain.def;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import java.util.List;
import org.junit.jupiter.api.Test;

class MetaJsonDtoSerializationTest {

  private final ObjectMapper objectMapper = new ObjectMapper();

  @Test
  void fieldCollection_shouldSerializeSchemaVersionAsUnderscoreV() throws Exception {
    FieldCollectionDef fields =
        new FieldCollectionDef(
            1,
            List.of(new FieldDef("name", "Name", FieldTypeEnum.TEXT, true, new FieldOptionsDef(1))));

    JsonNode json = objectMapper.valueToTree(fields);

    assertThat(json.get("_v").asInt()).isEqualTo(1);
    assertThat(json.get("items").get(0).get("code").asText()).isEqualTo("name");
  }

  @Test
  void commercialMetadata_shouldSerializeWithVersionAndRuntimeDisabled() throws Exception {
    CommercialMetadataDef commercial =
        new CommercialMetadataDef(
            1,
            List.of(
                new ObjectExtensionDef(
                    "customer",
                    "customer",
                    "customer",
                    "sales_pkg",
                    "1.0.0",
                    "field_add",
                    "reject",
                    List.of(new FieldDef("customer_level", "Customer Level", FieldTypeEnum.TEXT, false, new FieldOptionsDef(1))),
                    false)),
            List.of(new ConversionDef("order_to_invoice", "order", "invoice", false)),
            List.of(new LicensePolicyDef("offline", "read_only", true, true, true, false)));

    JsonNode json = objectMapper.valueToTree(commercial);

    assertThat(json.get("_v").asInt()).isEqualTo(1);
    assertThat(json.get("objectExtensions").get(0).get("runtimeEnabled").asBoolean()).isFalse();
    assertThat(json.get("objectExtensions").get(0).get("sourceKind").asText()).isEqualTo("customer");
    assertThat(json.get("conversions").get(0).get("runtimeEnabled").asBoolean()).isFalse();
    assertThat(json.get("licensePolicies").get(0).get("runtimeEnabled").asBoolean()).isFalse();
    assertThat(json.get("licensePolicies").get(0).get("degradePolicy").asText()).isEqualTo("read_only");
  }
}
