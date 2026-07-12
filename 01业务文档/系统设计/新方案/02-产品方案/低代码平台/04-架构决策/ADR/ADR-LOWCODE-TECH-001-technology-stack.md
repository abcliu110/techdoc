# ADR-LOWCODE-TECH-001: 技术栈

> 状态：accepted
> 日期：2026-07-05

## 背景

低代码平台需要同时支持 SaaS 和私有化部署，目标客户偏企业业务系统。团队已有 Java、MySQL、React、Ant Design 经验。

## 决策

- 后端：Java 21 + Spring Boot 3.4.x + Maven 多模块。
- 数据库：MySQL 8.0.x 首版唯一支持。
- 缓存/锁：Redis 7.x。
- 静态 ORM：MyBatis-Plus 用于平台元数据静态表。
- 动态业务数据：自研动态数据访问层。
- 前端：React 18 + TypeScript + Ant Design 5 + pnpm workspace。

## 理由

- Java/Spring Boot 适合企业级私有化和长期维护。
- MySQL 是团队最熟悉的数据库，动态 DDL 风险可控性高于多数据库首版适配。
- React/AntD 与团队现有能力匹配，适合设计器类后台产品。
- 动态业务表运行时创建，静态 ORM 不能覆盖，必须自研动态访问层。

## 否决方案

- Node.js 全栈：更接近 NocoBase，但团队长期维护成本更高。
- Python/Frappe 同栈：不匹配团队主技术栈。
- 首版多数据库：增加 Schema Sync 和类型系统复杂度，推迟到 Connector/多数据源阶段。

## 后果

- 可复用团队 Java/MySQL/React 经验。
- 需要自研动态 SQL、Schema Sync、类型转换和权限注入。
- Frappe/NocoBase 只能学习模型和设计思想，不能直接复用代码。

## 验证

- T-001 建立 Maven 多模块、pnpm workspace、MySQL/Redis docker-compose。
- T-002~T-005 均基于 MySQL Testcontainers 验证。

