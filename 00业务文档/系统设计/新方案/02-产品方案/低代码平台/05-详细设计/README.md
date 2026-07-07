# 低代码平台详细设计索引

> 用途：执行 AI 开始任一里程碑代码前的详细设计入口。M0~M3 均必须从本文件定位对应任务设计和测试规格。

## 阅读顺序

1. `../03-需求/PRD-产品需求规格说明书.md`
2. `../04-架构决策/00-总体架构与技术选型.md`
3. `../04-架构决策/01-元模型设计.md`
4. `../04-架构决策/02-运行时引擎设计.md`
5. `../04-架构决策/03-设计器与前端设计.md`
6. `../07-知识库同步/07-低代码平台级架构陷阱与高难度问题清单.md`
7. `../../../../../工程规范/README.md`
8. `../../../../../工程规范/00-陷阱覆盖总表.md`
9. `08-详细设计总纲.md`
10. `../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md`
11. `../04-架构决策/ADR/ADR-LOWCODE-TECH-001-technology-stack.md`
12. `../04-架构决策/ADR/ADR-LOWCODE-ID-001-id-strategy.md`
13. `../04-架构决策/ADR/ADR-LOWCODE-STORE-001-metadata-json-aggregate.md`
14. `../04-架构决策/ADR/ADR-LOWCODE-M0-001-modular-monolith.md`
15. `../04-架构决策/ADR/ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md`
16. `../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md`
17. `../04-架构决策/ADR/ADR-LOWCODE-PERM-001-access-view-permission-core.md`（涉及权限、数据范围、owner 快照时必读）
18. `../04-架构决策/ADR/ADR-LOWCODE-OUTBOX-001-local-outbox-side-effects.md`（涉及发布副作用、通知、外部投递时必读）
19. `../04-架构决策/ADR/ADR-LOWCODE-OBJECT-EXT-001-business-object-extension.md`（涉及标准对象、行业模板、客户扩展时必读）
20. `../04-架构决策/ADR/ADR-LOWCODE-CONVERSION-001-document-conversion-writeback.md`（涉及单据转换、反写、引用追踪时必读）
21. `../04-架构决策/ADR/ADR-LOWCODE-FLEXORG-001-flexfield-multi-org-code-rule.md`（涉及弹性域、多组织、复杂编码时必读）
22. `../04-架构决策/ADR/ADR-LOWCODE-APP-PACKAGE-001-marketplace-license-lifecycle.md`（涉及应用包、市场、License 时必读）
23. `M1-M4-竞品特性补全详细设计.md`（涉及 T-107~T-108、T-207~T-214、T-311~T-320、M4 边界时必读）
24. 当前任务卡详细设计
25. 当前里程碑测试规格（`../06-任务与测试/测试规格/M0-测试规格.md` / `../06-任务与测试/测试规格/M1-测试规格.md` / `../06-任务与测试/测试规格/M2-测试规格.md` / `../06-任务与测试/测试规格/M3-测试规格.md`）

## 里程碑详细设计

```text
M0:
  T-001-工程骨架详细设计.md
  T-002-元数据表与实体层详细设计.md
  T-003-元模型领域服务详细设计.md
  T-004-SchemaSync动态DDL详细设计.md
  T-005-MetaGraph缓存详细设计.md
  ../06-任务与测试/测试规格/M0-测试规格.md

M1:
  T-101-表达式引擎详细设计.md
  T-102-动态数据API详细设计.md
  T-103-权限判定链详细设计.md
  T-104-状态机动作规则详细设计.md（同时承接 T-104 状态机动作与 T-105 规则引擎）
  T-106-性能基准与指标详细设计.md
  ../06-任务与测试/测试规格/M1-测试规格.md

M2:
  T-201-Renderer字段组件库详细设计.md
  T-202-默认页面详细设计.md
  T-203-ModelBuilder详细设计.md
  T-204-状态机权限配置界面详细设计.md
  T-205-页面Schema编辑详细设计.md
  T-206-版本发布与前端集成详细设计.md
  ../06-任务与测试/测试规格/M2-测试规格.md

M3:
  T-301-工作流运行时详细设计.md
  T-302-T303-插件生命周期与字段扩展详细设计.md
  T-304-T305-导入导出包与Connector详细设计.md
  T-306-通知通道详细设计.md
  T-307-T310-商用业务能力详细设计.md
  ../06-任务与测试/测试规格/M3-测试规格.md
```

## 执行顺序

```text
M0:
  T-001 -> T-002 -> T-003 -> T-004
                      └-----> T-005

M1:
  T-101 -> T-102a -> T-103 -> T-102b -> T-104 -> T-105 -> T-106

M2:
  T-201 -> T-202 -> T-203 -> T-204 -> T-205 -> T-206

M3:
  T-301
  T-302 -> T-303
  T-304 -> T-305
  T-306
  T-307 -> T-308 -> T-309 -> T-310
```

T-004 和 T-005 都依赖 T-003；T-005 不依赖 T-004。

## 开工规则

- 每个任务只实现自己的详细设计，不顺手实现后续任务。
- 每个任务必须提交测试证据。
- 发现详细设计与 PRD、架构设计、公共工程规范 00/09~28 或 ADR 冲突时，停止实现并上报。
- 涉及单向门的新决策必须新增 ADR。
- REQ-070~REQ-078 在 M0 只能做 DTO、枚举、快照承载、引用提取和误执行阻断；不得顺手实现单据继承、转换、反写、弹性域查询、报表运行、菜单门户、包市场或 License 运行时。
- REQ-079~REQ-090 的定价打包、运营指标、表达式版本、元数据迁移、租户生命周期和竞品复核要求，必须在 M1~M3 对应任务中按测试规格落地；不得只停留在 PRD。
- 知识库标注“未验证”“源码初证”“高可信推断”的依据，进入不可逆实现前必须补充实测证据、源码证据或 ADR 风险接受记录。
