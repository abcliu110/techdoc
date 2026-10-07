# 内容审核报告

## 审核日期
2026-10-06

## 审核范围
- fraction-comparison (6个步骤)
- unit-unification (5个步骤)
- whole-part-thinking (5个步骤)
- transformation (5个步骤)
- equation-reasoning (5个步骤)

## 格式验证结果
✅ 所有26个JSON文件格式验证通过

## 数学内容验证
✅ 所有数学计算正确

## 需要修复的问题

### 1. 多余文件需删除
```
src/content/kps/unit-unification/concrete.json    (与steps/concrete.json重复)
src/content/kps/unit-unification/symbolic.json   (与steps/symbolic.json重复)
src/content/kps/unit-unification/application.json (与steps/application.json重复)
```

### 2. ConcreteStep visualType 字段映射
| visualType | 需要的组件 | 状态 |
|------------|-----------|------|
| split-circle | SplitCircle | ✅ 已有 |
| shapes | ShapesVisual | ❌ 需创建 |
| ruler | RulerVisual | ❌ 需创建 |
| balance | BalanceVisual | ❌ 需创建 |
| apples | ApplesVisual | ❌ 需创建 |

### 3. JSON visualType 与规范对照
| 文件 | JSON中的visualType | 需要创建的可视化组件 |
|------|-------------------|---------------------|
| unit-unification/concrete.json | ruler | RulerVisual |
| whole-part-thinking/concrete.json | apples | ApplesVisual |
| transformation/concrete.json | shapes | ShapesVisual |
| equation-reasoning/concrete.json | balance | BalanceVisual |

## 建议
1. 删除 unit-unification 根目录下3个重复文件
2. 前端开发创建4个新的可视化组件
3. 更新 FileSystemContentRepository 移除重复文件引用
