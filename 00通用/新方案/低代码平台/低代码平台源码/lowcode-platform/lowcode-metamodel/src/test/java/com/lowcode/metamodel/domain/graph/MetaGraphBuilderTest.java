package com.lowcode.metamodel.domain.graph;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.List;
import org.junit.jupiter.api.Test;

class MetaGraphBuilderTest {

  @Test
  void build_从发布快照构建对象字段和关系索引() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                new FieldDef("name", "名称", FieldTypeEnum.TEXT, true, FieldOptionsDef.text(1, 128)),
                new FieldDef("customer", "客户", FieldTypeEnum.LINK, false, FieldOptionsDef.link(1, "customer"))));
    AppSnapshotDef snapshot = snapshot("sales", "v1", List.of(order));

    MetaGraph graph = new MetaGraphBuilder().build(snapshot);

    assertThat(graph.tenantId()).isEqualTo(1L);
    assertThat(graph.appCode()).isEqualTo("sales");
    assertThat(graph.metaVersion()).isEqualTo("v1");
    assertThat(graph.object("order").fieldsByCode()).containsKeys("name", "customer");
    assertThat(graph.object("order").relationsByCode()).containsKey("customer");
    assertThat(graph.refsFrom("order")).singleElement().satisfies(ref -> assertThat(ref.targetCode()).isEqualTo("customer"));
  }

  @Test
  void build_返回不可变图_外部不能修改对象索引() {
    MetaGraph graph = new MetaGraphBuilder().build(snapshot("sales", "v1", List.of()));

    assertThatThrownBy(() -> graph.objectsByCode().clear()).isInstanceOf(UnsupportedOperationException.class);
  }

  @Test
  void build_未来快照版本_阻断加载() {
    AppSnapshotDef snapshot = new AppSnapshotDef(99, 1L, "sales", "v1", List.of(), List.of(), List.of(), List.of(), List.of(), CommercialMetadataDef.empty(1));

    assertThatThrownBy(() -> new MetaGraphBuilder().build(snapshot))
        .isInstanceOf(MetaGraphLoadException.class)
        .hasMessageContaining("快照版本不兼容");
  }

  static AppSnapshotDef snapshot(String appCode, String versionNo, List<Object> objects) {
    return new AppSnapshotDef(1, 1L, appCode, versionNo, objects, List.of(), List.of(), List.of(), List.of(), CommercialMetadataDef.empty(1));
  }
}
