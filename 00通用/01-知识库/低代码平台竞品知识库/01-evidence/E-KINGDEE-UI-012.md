---
id: E-KINGDEE-UI-012
type: evidence
competitor: Kingdee-Cosmic
module: form-field-runtime-ui
source_channel: official-doc
source_type: developer-guide-screenshot
source_url: https://vip.kingdee.com/knowledge/specialDetail/218022218066869248?category=248483045102409216&id=215128684791905280&type=Knowledge&productLineId=29&lang=zh-CN
source_owner: competitor-official
captured_at: 2026-07-08
valid_until: 2026-10-08
license_note: public-page-reference-only
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：金蝶字段控件运行态视觉样式

## 原始观察

金蝶开发平台公开文档“文本字段”“下拉列表字段”“基础资料字段”“字段布局面板”等文章包含字段控件运行态截图。

关键截图来源：

| 场景 | 官方图片 URL | 本轮测量尺寸 |
|---|---|---|
| 文本字段风格对比：基本、禁用、有限随按钮、Tips、必录、边框 | https://vip.kingdee.com/download/010070e33310fa2544dc983337d2bb063003.png | 889 x 750 |
| 下拉列表展开态 | https://vip.kingdee.com/download/01007561afcfafe248469b102e0b86af6632.png | 488 x 244 |
| 基础资料字段下拉/F7类选择态 | https://vip.kingdee.com/download/01000b997ade946746658ae59d42fe12f603.png | 382 x 434 |
| 字段布局面板，两列字段布局示例 | https://vip.kingdee.com/download/0100db19cf12216f44edae1fe50df9236129.png | 1274 x 794 |

可见样式：

- 默认字段以“标签 + 值/输入区 + 底部细线”为主，不是厚边框输入框。
- 激活态底线变为蓝色；必录/校验错误使用红色星号、红色底线和红色错误文案。
- 禁用态使用浅灰背景或浅灰文字弱化。
- 下拉浮层为白底、轻阴影，列表项行高较大，选中项使用浅蓝背景。
- 字段布局面板可呈两列网格，外层容器使用浅灰或虚线边框。

## 证据强度

直接事实：字段控件截图来自金蝶官方开发者社区公开文档，可直接证明运行态字段控件的主要视觉样式。

推断边界：这些截图不能证明所有终端、主题、移动端和暗色模式表现，也不能替代对实际产品版本的交互实测。

## 可抽取知识

- 企业后台表单可以采用下划线式字段作为默认密集录入样式，再为特殊场景提供边框模式。
- 校验错误需要同时用颜色、线条和文字提示，不能只靠红色星号。
- 选择类控件的浮层需要轻量、行高足够、选中态明确。
- 布局容器应通过边框、间距和列宽建立结构感，而不是用大面积卡片堆叠。

