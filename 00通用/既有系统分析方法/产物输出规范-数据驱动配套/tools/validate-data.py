#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""数据文件校验器：结构、枚举、ID 模式、跨文件引用一致性。

用法：
  python validate-data.py [data_dir]
  缺省 data_dir = ../data/示例-订单创建

退出码：0 = 全部通过；1 = 存在错误。
"""
import io
import re
import sys
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent.parent
SCHEMA_PATH = HERE / "schemas" / "artifacts.schema.yaml"

sys.stdout.reconfigure(encoding="utf-8")


def load_yaml(path):
    with io.open(path, "r", encoding="utf-8-sig") as f:
        return yaml.safe_load(f) or {}


def as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


class Validator:
    def __init__(self, schema, data):
        self.schema = schema
        self.data = data
        self.errors = []
        self.checks = 0

    def err(self, msg):
        self.errors.append(msg)

    # ---- 单对象字段校验 ----
    def validate_object(self, obj_type, obj, where):
        spec = self.schema["objects"][obj_type]
        enums = self.schema["enums"]
        for field in spec.get("required", []):
            if field not in obj or obj[field] in (None, "", []):
                self.err("%s: 缺少必填字段 '%s'" % (where, field))
        for field, enum_name in spec.get("enums", {}).items():
            if field in obj and obj[field] is not None:
                if obj[field] not in enums[enum_name]:
                    self.err("%s: 字段 '%s' 值 '%s' 不在枚举 %s 中"
                             % (where, field, obj[field], enums[enum_name]))
        id_field = spec.get("id_field")
        if id_field and id_field in obj:
            pattern = spec.get("id_pattern")
            if pattern and not re.match(pattern, str(obj[id_field])):
                self.err("%s: ID '%s' 不符合模式 %s" % (where, obj[id_field], pattern))
        # 递归校验子对象（attributes / children.attributes / rows 等）
        for child_type, key in (("attribute_list", "attributes"),):
            pass  # 属性为弱结构，仅做证据引用检查（见 cross checks）

    def run(self):
        s = self.schema
        # 1) 顶层键
        for fname, allowed in s["top_keys"].items():
            if fname in self.data:
                for key in self.data[fname]:
                    if key not in allowed:
                        self.err("%s: 未定义的顶层键 '%s'（允许: %s）" % (fname, key, allowed))

        # 2) 逐对象校验 + 收集 ID
        ids = {}
        for obj_type, spec in s["objects"].items():
            fname, key = spec["file"], spec["key"]
            items = as_list(self.data.get(fname, {}).get(key))
            for obj in items:
                where = "%s#%s" % (fname, obj_type)
                self.validate_object(obj_type, obj, where)
                idf = spec.get("id_field")
                if idf and idf in obj:
                    oid = str(obj[idf])
                    if oid in ids:
                        self.err("%s: ID '%s' 重复定义（先前见于 %s）" % (where, oid, ids[oid]))
                    ids[oid] = where
        self.checks += 1

        context_ids = {c.get("id") for c in as_list(self.data.get("entities.yaml", {}).get("contexts"))}
        rule_ids = {r.get("id") for r in as_list(self.data.get("rules.yaml", {}).get("rules"))}
        agg_names = {a.get("name") for a in as_list(self.data.get("entities.yaml", {}).get("aggregates"))}
        child_names = set()
        for a in as_list(self.data.get("entities.yaml", {}).get("aggregates")):
            for ch in as_list(a.get("children")):
                child_names.add(ch.get("name"))
        evidence_ids = {e.get("id") for e in as_list(self.data.get("evidence.yaml", {}).get("evidence"))}

        # 3) 跨文件引用
        for d in as_list(self.data.get("rules.yaml", {}).get("dependencies")):
            for end in ("from", "to"):
                if d.get(end) not in rule_ids:
                    self.err("rules.yaml#dependencies: 依赖端点 '%s' 不是已登记规则" % d.get(end))

        for r in as_list(self.data.get("rules.yaml", {}).get("rules")):
            if r.get("context") not in context_ids:
                self.err("rules.yaml: 规则 %s 的 context '%s' 未登记" % (r.get("id"), r.get("context")))
            for ev in as_list(r.get("evidence")):
                if ev not in evidence_ids:
                    self.err("rules.yaml: 规则 %s 引用不存在的证据 '%s'" % (r.get("id"), ev))

        exec_orders = [r["exec_order"] for r in as_list(self.data.get("rules.yaml", {}).get("rules"))
                       if r.get("exec_order") is not None]
        if len(exec_orders) != len(set(exec_orders)):
            self.err("rules.yaml: exec_order 存在重复，执行顺序不唯一")

        for sm in as_list(self.data.get("states.yaml", {}).get("state_machines")):
            codes = {st.get("code") for st in as_list(sm.get("states"))}
            for t in as_list(sm.get("transitions")):
                for end in ("from", "to"):
                    if t.get(end) not in codes:
                        self.err("states.yaml: 状态机 %s 转换 %s 的 '%s' 状态 '%s' 未定义"
                                 % (sm.get("id"), t.get("id"), end, t.get(end)))
            for it in as_list(sm.get("illegal_transitions")):
                if it.get("from") not in codes:
                    self.err("states.yaml: 状态机 %s 非法转换的源状态 '%s' 未定义" % (sm.get("id"), it.get("from")))

        for m in as_list(self.data.get("decisions.yaml", {}).get("decision_matrices")):
            n = len(as_list(m.get("conditions")))
            for row in as_list(m.get("rows")):
                if len(as_list(row.get("conditions"))) != n:
                    self.err("decisions.yaml: 矩阵 %s 某行条件数与表头不一致" % m.get("id"))
                if row.get("evidence") and row["evidence"] not in evidence_ids:
                    self.err("decisions.yaml: 矩阵 %s 引用不存在的证据 '%s'" % (m.get("id"), row["evidence"]))

        for f in as_list(self.data.get("flows.yaml", {}).get("flows")):
            if f.get("context") not in context_ids:
                self.err("flows.yaml: 流程 %s 的 context '%s' 未登记" % (f.get("id"), f.get("context")))

        for g in as_list(self.data.get("quality.yaml", {}).get("test_gaps")):
            if g.get("context") not in context_ids:
                self.err("quality.yaml: 缺口 %s 的 context '%s' 未登记" % (g.get("id"), g.get("context")))

        for a in as_list(self.data.get("entities.yaml", {}).get("aggregates")):
            for c in as_list(a.get("contexts")):
                if c not in context_ids:
                    self.err("entities.yaml: 聚合根 %s 引用未登记上下文 '%s'" % (a.get("id"), c))
            for rel in as_list(a.get("relations")):
                for end in ("from", "to"):
                    if rel.get(end) not in (agg_names | child_names):
                        self.err("entities.yaml: 聚合根 %s 关系端点 '%s' 未定义" % (a.get("id"), rel.get(end)))
            for attr in as_list(a.get("attributes")):
                ev = attr.get("evidence")
                if ev and ev not in evidence_ids:
                    self.err("entities.yaml: 聚合根 %s 属性 %s 引用不存在的证据 '%s'"
                             % (a.get("id"), attr.get("name"), ev))
            for ch in as_list(a.get("children")):
                for attr in as_list(ch.get("attributes")):
                    ev = attr.get("evidence")
                    if ev and ev not in evidence_ids:
                        self.err("entities.yaml: 聚合根 %s 子对象 %s 属性 %s 引用不存在的证据 '%s'"
                                 % (a.get("id"), ch.get("name"), attr.get("name"), ev))
        self.checks += 1

        # 4) 证据引用全量扫描（任何对象里出现的 evidence 字段都要存在）
        def walk(node, where):
            if isinstance(node, dict):
                for k, v in node.items():
                    if k in ("evidence", "evidences") and v is not None:
                        for ev in as_list(v):
                            if isinstance(ev, str) and ev.startswith("EVD-") and ev not in evidence_ids:
                                self.err("%s: 引用不存在的证据 '%s'" % (where, ev))
                    else:
                        walk(v, where)
            elif isinstance(node, list):
                for i, v in enumerate(node):
                    walk(v, "%s[%d]" % (where, i))

        for fname, doc in self.data.items():
            walk(doc, fname)
        self.checks += 1


def main():
    schema = load_yaml(SCHEMA_PATH)
    data_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / "data" / "示例-订单创建"
    if not data_dir.is_dir():
        print("数据目录不存在: %s" % data_dir)
        return 1
    data = {}
    for f in sorted(data_dir.glob("*.yaml")):
        data[f.name] = load_yaml(f)
    if not data:
        print("数据目录中没有 yaml 文件: %s" % data_dir)
        return 1

    v = Validator(schema, data)
    v.run()

    print("校验目录: %s" % data_dir)
    print("数据文件: %s" % ", ".join(sorted(data)))
    print("检查组: %d" % v.checks)
    if v.errors:
        print("结果: FAIL（%d 个错误）" % len(v.errors))
        for e in v.errors:
            print("  [ERROR] %s" % e)
        return 1
    print("结果: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
