# 知识库目录说明

本目录用于存放各业务领域或产品方向的知识库。

知识库是证据和领域认知资产，包含竞品官网资料、截图拆解、试用实测、源码分析、能力矩阵、痛点机会、设计原则和缺口清单。

## 当前知识库

```text
低代码平台竞品知识库/
```

## 建库规则

1. 一个领域一个知识库目录。
2. 知识库不直接放 PRD、源码实现、任务卡；这些属于 `02-产品方案/`。
3. 知识库结论必须能追溯到证据卡。
4. 未验证竞品结论必须标注为假设或待验证，不得直接支撑产品决策。
5. 知识库可被多个产品方案复用。

## 推荐知识库结构

```text
某领域知识库/
  README.md
  00-domain/
  01-evidence/
  02-competitors/
  03-ui-design/
  04-process/
  05-data-model/
  06-state-machine/
  07-business-rule/
  08-permission/
  09-pain-point/
  10-decision/
  11-metrics/
  12-non-functional/
  13-license-pricing/
  matrices/
  gaps/
```
