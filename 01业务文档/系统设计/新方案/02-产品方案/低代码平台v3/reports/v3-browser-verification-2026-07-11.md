# V3 浏览器验证报告（2026-07-11）

## 环境

- URL：`http://127.0.0.1:4173/`
- 浏览器：Codex 内置浏览器
- 视口：1280x800、1440x900、1920x1080、390x844
- 页面：`低代码设计中心 - 销售订单`

## 结果

| 检查项 | 结果 | 证据 |
|---|---|---|
| 页面身份与首屏 | 通过 | 标题、工作台区域和 106 个组件目录可见 |
| 添加组件 | 通过 | 节点数 2 -> 3，Schema 出现 `TextField`，状态显示“已添加单行文本” |
| 撤销/重做 | 通过 | 节点数 3 -> 2 -> 3 |
| 本地恢复 | 通过 | 刷新后节点数 3、`TextField`、手机设备和审核态均恢复 |
| 动态大纲与属性 | 通过 | 大纲出现 `text-field-1`，选中后属性标题为“单行文本” |
| 设备与业务状态 | 通过 | Canvas 切换为 `mobile`，业务状态切换为 `approve` |
| 运行预览 | 通过 | 预览面包含新增“单行文本”组件 |
| 桌面几何 | 通过 | 1440x900 页面无横向溢出，画布可见 |
| 手机几何 | 通过 | 390x844 页面 `scrollWidth=390`，画布宽 390、x=0；资源/属性面板隐藏 |
| 控制台健康 | 通过 | 完整交互路径 error/warn 为 0 |

截图：`screenshots/v3-desktop-1280x800.png`、`screenshots/v3-desktop-1920x1080.png`、`screenshots/v3-mobile-390x844.png`。

## 自动化门禁

```powershell
node --test tests/*.test.mjs
node --check prototype/app.js
node --check prototype/schema-engine.mjs
node --check prototype/component-registry.mjs
```

结果：50/50 测试通过，三个语法检查退出码均为 0。

## 真实性边界

- 106 是组件协议目录数量，不代表 106 个组件都已有生产级专用 Renderer。
- 子单据体关系使用原型默认实体和主外键，仅用于验证关系约束与嵌套流程。
- 未连接真实数据库、权限中心、工作流引擎和发布服务。
