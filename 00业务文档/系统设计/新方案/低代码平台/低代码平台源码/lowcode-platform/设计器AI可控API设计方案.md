# 设计器AI可控API设计方案

## 核心理念
**人能做的操作，AI也必须能做**

设计器必须暴露编程接口（API），让AI可以：
1. 模拟拖拽操作
2. 添加/删除/移动组件
3. 修改属性
4. 切换视图
5. 保存/加载表单

## 设计方案

### 1. 设计器控制器（DesignerController）

```typescript
interface DesignerController {
  // 组件操作
  addField(type: string, parentId?: string): Field;
  removeField(id: string): void;
  moveField(id: string, targetParentId: string | null, index: number): void;
  selectField(id: string): void;
  
  // 属性修改
  updateField(id: string, updates: Partial<Field>): void;
  
  // 布局操作
  setFieldLayout(id: string, layout: 'vertical' | 'horizontal' | 'grid'): void;
  setFieldSize(id: string, width?: string, height?: string): void;
  
  // 视图切换
  setViewMode(mode: 'design' | 'preview' | 'code'): void;
  
  // 数据获取
  getFields(): Field[];
  getField(id: string): Field | null;
  getSelectedField(): Field | null;
  
  // 保存/加载
  save(): FormDefinition;
  load(definition: FormDefinition): void;
}
```

### 2. 测试API

```typescript
// AI可以这样测试拖拽功能
test('AI模拟拖拽：从组件面板到画布', () => {
  const controller = new DesignerController();
  
  // 1. 添加input到画布
  const field = controller.addField('input');
  expect(controller.getFields().length).toBe(1);
  expect(field.type).toBe('input');
  
  // 2. 修改宽度
  controller.updateField(field.id, { width: '200px' });
  expect(controller.getField(field.id)?.width).toBe('200px');
  
  // 3. 切换到预览模式
  controller.setViewMode('preview');
  expect(controller.getViewMode()).toBe('preview');
});

test('AI模拟拖拽：组件到容器内', () => {
  const controller = new DesignerController();
  
  // 1. 添加Card
  const card = controller.addField('card');
  
  // 2. 添加Input到Card内
  const input = controller.addField('input', card.id);
  expect(input.parentId).toBe(card.id);
  
  // 3. 设置Card布局为网格
  controller.setFieldLayout(card.id, 'grid');
  controller.updateField(card.id, { gridColumns: 3 });
  
  // 4. 验证
  const updatedCard = controller.getField(card.id);
  expect(updatedCard?.childLayout).toBe('grid');
  expect(updatedCard?.gridColumns).toBe(3);
});
```

### 3. 集成到设计器

```typescript
// FormDesignerNested.tsx
export const FormDesignerNested: React.FC = () => {
  const [controller] = useState(() => new DesignerController());
  
  // 暴露到window，让测试可以访问
  useEffect(() => {
    (window as any).__designerController = controller;
  }, [controller]);
  
  return (
    <DesignerControllerContext.Provider value={controller}>
      {/* 现有UI */}
    </DesignerControllerContext.Provider>
  );
};
```

### 4. E2E测试示例

```typescript
// Playwright E2E测试（AI可以运行）
test('完整拖拽流程测试', async ({ page }) => {
  await page.goto('http://localhost:3000');
  
  // 获取controller
  const controller = await page.evaluate(() => {
    return (window as any).__designerController;
  });
  
  // AI通过controller操作
  await page.evaluate((ctrl) => {
    // 添加Card
    const card = ctrl.addField('card');
    
    // 添加3个Input到Card内
    ctrl.addField('input', card.id);
    ctrl.addField('input', card.id);
    ctrl.addField('input', card.id);
    
    // 设置网格布局
    ctrl.setFieldLayout(card.id, 'grid');
    ctrl.updateField(card.id, { gridColumns: 2 });
  }, controller);
  
  // 验证UI更新
  await expect(page.locator('.ant-card').count()).resolves.toBe(1);
  await expect(page.locator('input').count()).resolves.toBe(3);
});
```

## 优势

### 对AI
1. ✅ 不依赖DOM - 纯逻辑测试
2. ✅ 可预测 - 确定性的输入输出
3. ✅ 快速 - 无需启动浏览器
4. ✅ 完整 - 覆盖所有用户操作

### 对开发
1. ✅ 自动化测试
2. ✅ 回归测试
3. ✅ 性能测试
4. ✅ 集成测试

### 对用户
1. ✅ 更稳定 - 充分测试
2. ✅ 更可靠 - 每次提交都测试
3. ✅ 更快速 - AI发现bug更早

## 实施步骤

### Phase 1: 核心Controller（立即）
- [x] 定义DesignerController接口
- [ ] 实现基础方法（add/remove/update）
- [ ] 集成到FormDesignerNested

### Phase 2: 测试覆盖（1天）
- [ ] 添加30+个Controller测试
- [ ] 拖拽、布局、属性修改测试
- [ ] 边界情况测试

### Phase 3: E2E测试（可选）
- [ ] Playwright集成
- [ ] 视觉回归测试
- [ ] 性能测试

## 示例：完整测试套件

```typescript
describe('DesignerController - 完整功能测试', () => {
  let controller: DesignerController;
  
  beforeEach(() => {
    controller = new DesignerController();
  });
  
  describe('组件库', () => {
    test('应该有27个组件', () => {
      const components = controller.getAvailableComponents();
      expect(components.length).toBe(27);
    });
    
    test('应该有4个布局组件', () => {
      const layouts = controller.getAvailableComponents()
        .filter(c => c.category === 'layout');
      expect(layouts.length).toBe(4);
    });
  });
  
  describe('拖拽操作', () => {
    test('从面板到画布', () => {
      const field = controller.addField('input');
      expect(controller.getFields()).toHaveLength(1);
    });
    
    test('拖到容器内', () => {
      const card = controller.addField('card');
      const input = controller.addField('input', card.id);
      expect(input.parentId).toBe(card.id);
    });
    
    test('画布内排序', () => {
      controller.addField('input'); // id: 1
      controller.addField('select'); // id: 2
      controller.addField('date'); // id: 3
      
      controller.moveField('1', null, 2); // 移到最后
      const ids = controller.getFields().map(f => f.id);
      expect(ids).toEqual(['2', '3', '1']);
    });
  });
  
  describe('布局功能', () => {
    test('垂直布局', () => {
      const card = controller.addField('card');
      controller.setFieldLayout(card.id, 'vertical');
      expect(controller.getField(card.id)?.childLayout).toBe('vertical');
    });
    
    test('水平布局', () => {
      const card = controller.addField('card');
      controller.setFieldLayout(card.id, 'horizontal');
      expect(controller.getField(card.id)?.childLayout).toBe('horizontal');
    });
    
    test('网格布局', () => {
      const card = controller.addField('card');
      controller.setFieldLayout(card.id, 'grid');
      controller.updateField(card.id, { gridColumns: 3 });
      
      const field = controller.getField(card.id);
      expect(field?.childLayout).toBe('grid');
      expect(field?.gridColumns).toBe(3);
    });
  });
  
  describe('宽高配置', () => {
    test('设置宽度', () => {
      const field = controller.addField('input');
      controller.setFieldSize(field.id, '200px');
      expect(controller.getField(field.id)?.width).toBe('200px');
    });
    
    test('设置高度', () => {
      const field = controller.addField('input');
      controller.setFieldSize(field.id, undefined, '100px');
      expect(controller.getField(field.id)?.height).toBe('100px');
    });
  });
});
```

## 总结

这套方案让AI可以：
1. ✅ 完全控制设计器
2. ✅ 测试所有功能
3. ✅ 不依赖浏览器
4. ✅ 快速反馈

**就像给AI一个遥控器，可以操作设计器的所有功能！**
