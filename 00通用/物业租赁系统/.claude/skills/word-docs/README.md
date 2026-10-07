# word-docs — Word 文档日常办公 Claude Skill

一套日常办公 Word 文档助手技能（Skill）：写文档、清洗 AI 粘贴内容、统一他人 Word 格式、校对查错，输出统一规范的 Word 文档。

## 功能

四个使用入口，一套排版标准：

1. **写新文档** — 报告、分析、制度、通知、请示、函件，直接按规范生成
2. **清洗排版** — 把 AI 生成/复制粘贴的内容清掉 Markdown 残留（`#`、`*`、反引号），自动转换为「一、（一）1.（1）」序号体系；Word 自动编号转文字编号写死，复制导出永不错乱
3. **格式统一** — 别人发来的乱格式 Word，批量套用规范重排，只动格式不动文字
4. **校对检查** — 错别字/重复字/标点用 Word 批注给建议，存疑表述黄色高亮，表格合计自动验算；原文一律不直接改

核心规范：华文仿宋正文＋黑体标题（数字用仿宋、英文 Palatino 自动拆分）、投行风三线表（浅蓝表头、tblGrid 列网格、跨页表头重复）、层级序号连续校验，以及**数据红线**——不改数、不补数、空值不写 0、合计必验算。

## 目录结构

```
word-docs/
├── SKILL.md                    # 技能主文件（触发条件 + 全部排版规格）
├── references/
│   ├── word-gongwen.md         # 正式公文风变体
│   ├── word-modern.md          # 现代简洁风变体
│   ├── feishu.md               # 飞书文档输出规范
│   └── proofread.md            # 校对触发词清单与判定规则
└── scripts/
    └── docx_helpers.py         # python-docx 排版函数库（全部样式细节的成品实现）
```

## 安装

**Claude Cowork / Claude Desktop**：设置 → Capabilities → Skills，上传打包好的 `.zip` / `.skill`。

**Claude Code**：将 `word-docs/` 目录放入 `~/.claude/skills/`。

安装后无需手动调用——提到"写报告""排版""校对""整理文档"等场景会自动触发。

## 依赖

排版脚本需要 `python-docx ≥ 1.2`（批注功能依赖此版本）。

## 说明

这套规范是逐条讨论定稿的个人标准，字号、间距、表格样式均为定值。如需改成自己的口味，直接修改 `SKILL.md` 中「排版规格」一节和 `scripts/docx_helpers.py` 即可。

## License

MIT
