# T-207 Web表单设计器 - AI可测试性改进方案

## 问题
当前AI无法测试浏览器UI功能，只能依赖用户反馈，导致：
- 无法验证代码是否能正常运行
- 无法发现运行时错误
- 开发效率低

## 解决方案

### 方案1：单元测试（推荐）
**优点：**
- AI可以运行测试验证代码
- 自动化回归测试
- 快速发现bug

**实现：**
```typescript
// FormDesignerNested.test.tsx
describe('FormDesignerNested', () => {
  test('添加字段到画布', () => {
    const { result } = renderHook(() => useState([]));
    const handleAddField = (type: string) => {
      result.current[1]([...result.current[0], { type }]);
    };
    
    handleAddField('input');
    expect(result.current[0].length).toBe(1);
  });
});
```

### 方案2：集成测试（Playwright/Cypress）
**优点：**
- 端到端测试
- 真实浏览器环境

**缺点：**
- 需要启动浏览器（AI无法运行）

### 方案3：错误捕获和日志
**优点：**
- 运行时错误自动记录
- AI可以读取错误日志

**实现：**
```typescript
// ErrorBoundary.tsx
class ErrorBoundary extends React.Component {
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('❌ 运行时错误：', error, errorInfo);
    // 写入日志文件
    fetch('/api/log-error', {
      method: 'POST',
      body: JSON.stringify({ error: error.message, stack: error.stack })
    });
  }
}
```

### 方案4：TypeScript类型检查
**优点：**
- AI可以运行 `tsc --noEmit` 验证
- 编译时发现错误

**实现：**
```bash
# AI可以运行这个命令
pnpm tsc --noEmit
```

### 方案5：组件快照测试
**优点：**
- 防止UI意外变化
- AI可以运行测试

**实现：**
```typescript
test('FieldPreviewComplete snapshot', () => {
  const field = { type: 'input', label: '测试' };
  const tree = renderer.create(<FieldPreviewComplete field={field} />).toJSON();
  expect(tree).toMatchSnapshot();
});
```

## 推荐实施顺序

### 第1步：TypeScript类型检查（最快）
```bash
cd packages/demo
pnpm tsc --noEmit
```

### 第2步：添加基础单元测试
```bash
pnpm add -D @testing-library/react @testing-library/jest-dom vitest
```

### 第3步：添加ErrorBoundary
包裹整个应用，捕获运行时错误

### 第4步：集成测试（可选）
如果需要端到端测试

## 立即可做的改进

### A. 添加TypeScript严格模式
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

### B. 添加ESLint
```bash
pnpm add -D eslint @typescript-eslint/parser
pnpm eslint src/
```

### C. 添加控制台错误收集
```typescript
// main.tsx
window.addEventListener('error', (e) => {
  console.error('💥 全局错误：', e.message);
});
```

## 总结

**当前最佳方案：**
1. ✅ TypeScript类型检查（AI可运行）
2. ✅ 单元测试（AI可运行）
3. ✅ ErrorBoundary（捕获运行时错误）
4. ⏰ Playwright（需要用户反馈）

这样AI可以在提交代码前验证大部分问题！
