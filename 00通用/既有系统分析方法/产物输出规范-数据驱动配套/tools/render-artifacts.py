#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""产物生成器：从数据文件生成 Markdown 视图（统计表、索引、矩阵、mermaid 图）。

用法：
  python render-artifacts.py [data_dir] [out_dir]
  缺省 data_dir = ../data/示例-订单创建
  缺省 out_dir  = ../generated/示例-订单创建

生成视图禁止手改：所有输出文件头部带 generated 标记，check-artifacts.py 会校验标记完整。
"""
import io
import sys
from datetime import datetime
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent.parent
sys.stdout.reconfigure(encoding="utf-8")

NOW = datetime.now().strftime("%Y-%m-%d %H:%M")


def load_yaml(path):
    with io.open(path, "r", encoding="utf-8-sig") as f:
        return yaml.safe_load(f) or {}


def as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def md_table(header, rows):
    out = ["| " + " | ".join(header) + " |",
           "|" + "|".join(["------"] * len(header)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out)


def marker(sources):
    return ("<!-- generated from: %s | generator: render-artifacts.py | at: %s | "
            "本文件为生成视图，禁止手改；数据变更后重跑本工具 -->" % (sources, NOW))


class Renderer:
    def __init__(self, data):
        self.data = data

    # ---------- 规则视图 ----------
    def render_rules(self):
        rules = as_list(self.data.get("rules.yaml", {}).get("rules"))
        deps = as_list(self.data.get("rules.yaml", {}).get("dependencies"))
        parts = [marker("rules.yaml"),
                 "# 规则视图（生成）", "",
                 "## 1. 规则统计", ""]
        vis = sum(1 for r in rules if r.get("visibility") == "显性")
        conf = {}
        for r in rules:
            conf[r.get("confidence")] = conf.get(r.get("confidence"), 0) + 1
        pri = {}
        for r in rules:
            pri[r.get("priority")] = pri.get(r.get("priority"), 0) + 1
        parts.append(md_table(
            ["统计项", "数量"],
            [["规则总数", len(rules)], ["显性", vis], ["隐性", len(rules) - vis]]
            + [["P0", pri.get("P0", 0)], ["P1", pri.get("P1", 0)], ["P2", pri.get("P2", 0)]]
            + [["置信度 %s" % k, v] for k, v in sorted(conf.items())]))
        parts += ["", "## 2. 规则清单", ""]
        parts.append(md_table(
            ["规则ID", "名称", "类型", "显隐", "优先级", "置信度", "描述", "证据"],
            [[r["id"], r["name"], r["type"], r.get("visibility", "-"), r["priority"],
              r["confidence"], r["description"], "、".join(as_list(r.get("evidence")))]
             for r in rules]))
        ordered = sorted([r for r in rules if r.get("exec_order") is not None],
                         key=lambda r: r["exec_order"])
        if ordered:
            parts += ["", "## 3. 推荐执行顺序", ""]
            parts.append(md_table(["顺序", "规则ID", "名称", "理由"],
                                  [[r["exec_order"], r["id"], r["name"],
                                    "见规则描述与依赖边"] for r in ordered]))
        if deps:
            parts += ["", "## 4. 规则依赖图", "", "```mermaid", "graph TD"]
            for d in deps:
                parts.append("  %s -->|%s| %s" % (d["from"], d.get("type", "-"), d["to"]))
            parts += ["```"]
        if len(rules) <= 15:
            ids = [r["id"] for r in rules]
            edge_map = {(d["from"], d["to"]): d.get("type", "-") for d in deps}
            parts += ["", "## 5. 依赖矩阵", ""]
            parts.append(md_table([""] + ids,
                                  [[a] + [("-%s-" % edge_map[(a, b)]) if (a, b) in edge_map else "-" for b in ids]
                                   for a in ids]))
        highs = [r for r in rules if r.get("confidence") in ("L4", "L5")]
        lows = [r for r in rules if r.get("confidence") in ("L1", "L2")]
        if highs:
            parts += ["", "## 6. 高置信度规则（L4/L5）", ""]
            parts.append(md_table(["规则ID", "名称", "置信度", "证据"],
                                  [[r["id"], r["name"], r["confidence"], "、".join(as_list(r.get("evidence")))]
                                   for r in highs]))
        if lows:
            parts += ["", "## 7. 低置信度规则（L1/L2，待确认）", ""]
            parts.append(md_table(["规则ID", "名称", "置信度", "待确认项"],
                                  [[r["id"], r["name"], r["confidence"],
                                    "；".join(as_list(r.get("pending_questions"))) or "-"] for r in lows]))
        return "\n".join(parts) + "\n"

    # ---------- 状态机视图 ----------
    def render_states(self):
        machines = as_list(self.data.get("states.yaml", {}).get("state_machines"))
        parts = [marker("states.yaml"), "# 状态机视图（生成）", ""]
        for sm in machines:
            states = as_list(sm.get("states"))
            transitions = as_list(sm.get("transitions"))
            parts += ["## %s：%s 状态机" % (sm["id"], sm["object"]), ""]
            targets = {t["to"] for t in transitions}
            parts += ["```mermaid", "stateDiagram-v2"]
            entry = [st for st in states if st.get("initial")] \
                or [st for st in states if st["code"] not in targets] \
                or states[:1]
            for st in entry:
                parts.append("  [*] --> %s" % st["code"])
            for t in transitions:
                label = t["event"] + (": " + t["guard"] if t.get("guard") and t["guard"] != "无" else "")
                parts.append("  %s --> %s: %s" % (t["from"], t["to"], label))
            for st in states:
                if st.get("terminal"):
                    parts.append("  %s --> [*]" % st["code"])
            parts += ["```", ""]
            parts.append(md_table(
                ["转换ID", "当前状态", "事件/操作", "前置条件", "后置条件", "目标状态", "回滚", "置信度"],
                [[t["id"], t["from"], t["event"], t.get("guard", "-"), t.get("post", "-"),
                  t["to"], t.get("rollback", "-"), t.get("confidence", "-")] for t in transitions]))
            if sm.get("illegal_transitions"):
                parts += ["", "### 非法转换清单", ""]
                parts.append(md_table(["当前状态", "非法操作", "说明"],
                                      [[i["from"], i["action"], i["reason"]]
                                       for i in sm["illegal_transitions"]]))
            parts += ["", "### 状态持久化", ""]
            parts.append(md_table(["状态", "含义", "存储值", "是否终态"],
                                  [[st["code"], st["name_cn"], st.get("storage", "-"),
                                    "是" if st.get("terminal") else "否"] for st in states]))
            parts.append("")
        return "\n".join(parts)

    # ---------- 决策矩阵视图 ----------
    def render_decisions(self):
        matrices = as_list(self.data.get("decisions.yaml", {}).get("decision_matrices"))
        parts = [marker("decisions.yaml"), "# 决策矩阵视图（生成）", ""]
        for m in matrices:
            parts += ["## %s：%s（上下文 %s）" % (m["id"], m["name"], m.get("context", "-")), ""]
            header = ["条件%d：%s" % (i + 1, c) for i, c in enumerate(m["conditions"])] + ["结果", "代码位置", "证据"]
            rows = [list(r["conditions"]) + [r["result"], r.get("code", "-"), r.get("evidence", "-")]
                    for r in as_list(m.get("rows"))]
            parts.append(md_table(header, rows))
            parts.append("")
        return "\n".join(parts)

    # ---------- 流程视图 ----------
    def render_flows(self):
        flows = as_list(self.data.get("flows.yaml", {}).get("flows"))
        parts = [marker("flows.yaml"), "# 流程视图（生成）", ""]
        for f in flows:
            parts += ["## %s：%s（上下文 %s）" % (f["id"], f["name"], f.get("context", "-")), ""]
            parts.append(md_table(
                ["步骤", "操作", "输入/输出", "代码位置", "副作用", "可恢复性", "确定性", "证据"],
                [[s["no"], s["action"], s.get("io", "-"), s.get("code", "-"), s.get("side_effect", "-"),
                  s.get("recoverability", "-"), s.get("determinism", "-"), s.get("evidence", "-")]
                 for s in as_list(f.get("steps"))]))
            for key, title in (("variants", "变体流"), ("exceptions", "异常流"), ("compensations", "补偿流")):
                items = as_list(f.get(key))
                if items:
                    parts += ["", "### %s" % title, ""]
                    parts.append(md_table(["名称", "触发条件", "处理/差异", "幂等键", "重试", "兜底", "代码位置"],
                                          [[i.get("name", "-"), i.get("trigger", "-"),
                                            i.get("handling", i.get("code_diff", "-")),
                                            i.get("idempotency_key", "-"), i.get("retry", "-"),
                                            i.get("fallback", "-"), i.get("code", "-")] for i in items]))
            parts.append("")
        return "\n".join(parts)

    # ---------- 事件视图 ----------
    def render_events(self):
        events = as_list(self.data.get("events.yaml", {}).get("events"))
        parts = [marker("events.yaml"), "# 领域事件索引视图（生成）", ""]
        parts.append(md_table(
            ["事件ID", "事件", "聚合根", "触发时机", "Topic/Tag", "幂等键", "订阅方"],
            [[e["id"], e["name"], e["aggregate"], e["trigger"],
              "%s / %s" % (e.get("topic", "-"), e.get("tag", "-")),
              e.get("idempotency_key", "-"), "、".join(as_list(e.get("subscribers")))] for e in events]))
        parts += ["", "## 事件订阅关系图", "", "```mermaid", "graph LR"]
        for e in events:
            for s in as_list(e.get("subscribers")):
                parts.append("  %s -->|订阅| %s" % (e["name"], s))
        parts += ["```", ""]
        return "\n".join(parts)

    # ---------- 聚合根索引视图 ----------
    def render_entities(self):
        contexts = as_list(self.data.get("entities.yaml", {}).get("contexts"))
        aggs = as_list(self.data.get("entities.yaml", {}).get("aggregates"))
        parts = [marker("entities.yaml"), "# 聚合根索引视图（生成）", ""]
        parts.append(md_table(
            ["编号", "聚合根", "中文名", "类型", "状态", "业务域", "涉及上下文", "数据库表"],
            [[a["id"], a["name"], a.get("name_cn", "-"), a.get("kind", "-"), a.get("status", "-"),
              a.get("domain", "-"), "、".join(as_list(a.get("contexts"))), a.get("table", "-")]
             for a in aggs]))
        confirmed = sum(1 for a in aggs if a.get("status") == "已确认")
        candidate = sum(1 for a in aggs if a.get("status") == "候选")
        excluded = sum(1 for a in aggs if a.get("status") == "已排除")
        parts += ["", "统计：已确认 %d，候选 %d，已排除 %d。" % (confirmed, candidate, excluded), ""]
        parts += ["## 上下文清单", ""]
        parts.append(md_table(["上下文ID", "名称", "业务域", "优先级"],
                              [[c["id"], c["name"], c["domain"], c["priority"]] for c in contexts]))
        rels = [(a, r) for a in aggs for r in as_list(a.get("relations"))]
        if rels:
            parts += ["", "## 对象关系边表", ""]
            parts.append(md_table(["类型", "源", "目标", "多重性", "说明", "证据"],
                                  [[r["type"], r["from"], r["to"], r.get("multiplicity", "-"),
                                    r.get("note", "-"), r.get("evidence", "-")] for _, r in rels]))
            parts += ["", "## 聚合根依赖图", "", "```mermaid", "graph TD"]
            for a, r in rels:
                if r["type"] in ("引用", "创建", "关联"):
                    parts.append("  %s -->|%s| %s" % (r["from"], r["type"], r["to"]))
                else:
                    parts.append("  %s -->|%s| %s" % (r["from"], r["type"], r["to"]))
            parts += ["```", ""]
        return "\n".join(parts)

    # ---------- 质量视图 ----------
    def render_quality(self):
        debts = as_list(self.data.get("quality.yaml", {}).get("tech_debts"))
        gaps = as_list(self.data.get("quality.yaml", {}).get("test_gaps"))
        coverage = as_list(self.data.get("quality.yaml", {}).get("coverage"))
        parts = [marker("quality.yaml"), "# 质量视图（生成）", ""]
        by_pri = {}
        for d in debts:
            by_pri.setdefault(d["priority"], []).append(d)
        parts.append(md_table(["优先级", "数量", "预估工作量（人天）"],
                              [[p, len(items), sum(i.get("effort_days", 0) for i in items)]
                               for p, items in sorted(by_pri.items())]))
        parts += ["", "## 技术债务清单（权威登记处 = quality.yaml）", ""]
        parts.append(md_table(["债务ID", "描述", "影响", "优先级", "工作量(人天)", "负责人", "状态"],
                              [[d["id"], d["desc"], d["impact"], d["priority"], d["effort_days"],
                                d.get("owner", "-"), d.get("status", "-")] for d in debts]))
        if gaps:
            parts += ["", "## 测试缺口（权威登记处 = quality.yaml）", ""]
            parts.append(md_table(["缺口ID", "描述", "类型", "优先级", "上下文", "工作量(人天)", "负责人"],
                                  [[g["id"], g["desc"], g["type"], g["priority"], g["context"],
                                    g["effort_days"], g.get("owner", "-")] for g in gaps]))
        if coverage:
            parts += ["", "## 按上下文覆盖率", ""]
            parts.append(md_table(["上下文", "单元测试", "集成测试", "E2E", "达标情况"],
                                  [[c["context"], "%d%%" % c["unit"], "%d%%" % c["integration"],
                                    "%d%%" % c["e2e"],
                                    "✅" if (c["unit"] >= c["target_unit"] and c["integration"] >= c["target_integration"]
                                             and c["e2e"] >= c["target_e2e"]) else "⚠️未达标"]
                                   for c in coverage]))
        return "\n".join(parts) + "\n"


def main():
    data_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / "data" / "示例-订单创建"
    out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else HERE / "generated" / data_dir.name
    out_dir.mkdir(parents=True, exist_ok=True)

    data = {}
    for f in sorted(data_dir.glob("*.yaml")):
        data[f.name] = load_yaml(f)

    r = Renderer(data)
    views = [
        ("规则视图.md", r.render_rules()),
        ("状态机视图.md", r.render_states()),
        ("决策矩阵视图.md", r.render_decisions()),
        ("流程视图.md", r.render_flows()),
        ("事件索引视图.md", r.render_events()),
        ("聚合根索引视图.md", r.render_entities()),
        ("质量视图.md", r.render_quality()),
    ]

    # 汇总索引
    parts = [marker("全部数据文件"), "# 生成视图汇总索引", "",
             "> 本目录全部文件由 `render-artifacts.py` 生成，**禁止手改**；数据变更后重跑工具。", ""]
    for name, _ in views:
        parts.append("- [%s](./%s)" % (name, name))
    counts = []
    counts.append(("规则", len(as_list(data.get("rules.yaml", {}).get("rules")))))
    counts.append(("状态机", len(as_list(data.get("states.yaml", {}).get("state_machines")))))
    counts.append(("领域事件", len(as_list(data.get("events.yaml", {}).get("events")))))
    counts.append(("聚合根", len(as_list(data.get("entities.yaml", {}).get("aggregates")))))
    counts.append(("技术债务", len(as_list(data.get("quality.yaml", {}).get("tech_debts")))))
    counts.append(("测试缺口", len(as_list(data.get("quality.yaml", {}).get("test_gaps")))))
    parts += ["", "## 全局统计", "", md_table(["对象", "数量"], [[k, v] for k, v in counts]), ""]

    views.insert(0, ("00-汇总索引.md", "\n".join(parts)))

    for name, content in views:
        path = out_dir / name
        with io.open(path, "w", encoding="utf-8-sig", newline="\n") as f:
            f.write(content)
        print("生成: %s" % path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
