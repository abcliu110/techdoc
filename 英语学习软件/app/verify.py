# -*- coding: utf-8 -*-
with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'r', encoding='utf-8') as f:
    c = f.read()

checks = [
    ('五层分类架构', '### 3.1 五层分类架构' in c),
    ('词根词缀进入3.1表', '词根词缀 | 词根' in c),
    ('高中用户分层', '高中1-3年级' in c),
    ('grade_levels含senior', 'senior_1..3' in c),
    ('direction三值枚举', 'one_way' in c),
    ('direction注释', 'symmetric=同义反义' in c),
    ('cognitive_load注释', '认知负荷（加工难度）' in c),
    ('relation_type不含derived', 'derived,compound' not in c),
    ('K-12去重合计', 'K-12去重合计' in c),
    ('词条2400-2800', '2400-2800' in c),
    ('词素200-300', '词根200-300' in c),
    ('FSRS初始值', 'stability=0.1' in c),
    ('各维度落点说明', '各维度数据库落点' in c),
    ('3.5学段配置', '各学段学习模式配置' in c),
    ('3.7分类闭环', '3.7 分类驱动的最小闭环' in c),
    ('3.3.14语言关系', '3.3.14 语言关系维度总览' in c),
]

print('=== 修复验证 ===')
all_pass = True
for name, result in checks:
    status = 'PASS' if result else 'FAIL'
    if not result:
        all_pass = False
    print(f'  [{status}] {name}')

print()
print('总体结果:', '全部通过' if all_pass else '有失败项')
