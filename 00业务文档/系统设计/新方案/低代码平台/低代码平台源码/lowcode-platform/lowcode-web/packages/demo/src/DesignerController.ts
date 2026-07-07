/**
 * 设计器控制器 - 提供编程接口让AI可以操作设计器
 *
 * 核心理念：人能做的操作，AI也必须能做
 */

export interface Field {
  id: string;
  fieldId: string;
  label: string;
  type: string;
  parentId?: string | null;
  children?: Field[];
  [key: string]: any;
}

export interface FormDefinition {
  formId: string;
  formName: string;
  version: string;
  fields: Field[];
}

export interface ComponentDefinition {
  type: string;
  label: string;
  icon: string;
  category: 'basic' | 'advanced' | 'layout' | 'high-level';
}

export class DesignerController {
  private fields: Field[] = [];
  private selectedId: string | null = null;
  private viewMode: 'design' | 'preview' | 'code' = 'design';
  private nextId = 1;

  // ========== 组件操作 ==========

  /**
   * 添加字段到画布或容器内
   * 模拟：从组件面板拖动到画布/容器
   */
  addField(type: string, parentId?: string | null, options?: Partial<Field>): Field {
    const newField: Field = {
      id: `field_${this.nextId++}`,
      fieldId: `field_${Date.now()}`,
      label: options?.label || `新${type}字段`,
      type,
      parentId: parentId || null,
      ...options,
    };

    this.fields.push(newField);
    this.selectedId = newField.id;

    return newField;
  }

  /**
   * 删除字段
   * 模拟：点击删除按钮
   */
  removeField(id: string): boolean {
    const index = this.fields.findIndex(f => f.id === id);
    if (index === -1) return false;

    this.fields.splice(index, 1);

    if (this.selectedId === id) {
      this.selectedId = null;
    }

    return true;
  }

  /**
   * 移动字段到新位置
   * 模拟：拖拽排序 或 拖到另一个容器
   */
  moveField(id: string, targetParentId: string | null, index?: number): boolean {
    const fieldIndex = this.fields.findIndex(f => f.id === id);
    if (fieldIndex === -1) return false;

    const field = this.fields[fieldIndex];
    field.parentId = targetParentId;

    // 如果指定了index，调整顺序
    if (index !== undefined) {
      this.fields.splice(fieldIndex, 1);
      this.fields.splice(index, 0, field);
    }

    return true;
  }

  /**
   * 选中字段
   * 模拟：点击字段
   */
  selectField(id: string | null): boolean {
    if (id !== null && !this.fields.find(f => f.id === id)) {
      return false;
    }

    this.selectedId = id;
    return true;
  }

  // ========== 属性修改 ==========

  /**
   * 更新字段属性
   * 模拟：在属性面板修改属性
   */
  updateField(id: string, updates: Partial<Field>): boolean {
    const field = this.fields.find(f => f.id === id);
    if (!field) return false;

    Object.assign(field, updates);
    return true;
  }

  /**
   * 设置字段宽高
   * 模拟：在属性面板设置宽高
   */
  setFieldSize(id: string, width?: string, height?: string): boolean {
    return this.updateField(id, { width, height });
  }

  /**
   * 设置容器布局
   * 模拟：在布局配置面板设置布局方式
   */
  setFieldLayout(id: string, layout: 'vertical' | 'horizontal' | 'grid'): boolean {
    return this.updateField(id, { childLayout: layout });
  }

  /**
   * 设置网格列数
   * 模拟：在布局配置面板设置列数
   */
  setGridColumns(id: string, columns: number): boolean {
    return this.updateField(id, { gridColumns: columns });
  }

  /**
   * 添加选项（用于select/radio/checkbox）
   * 模拟：在数据配置面板添加选项
   */
  addOption(id: string, label: string, value: string): boolean {
    const field = this.fields.find(f => f.id === id);
    if (!field) return false;

    const options = field.options || [];
    options.push({ label, value });
    field.options = options;

    return true;
  }

  // ========== 视图切换 ==========

  /**
   * 切换视图模式
   * 模拟：点击Tab切换
   */
  setViewMode(mode: 'design' | 'preview' | 'code'): void {
    this.viewMode = mode;
  }

  getViewMode(): 'design' | 'preview' | 'code' {
    return this.viewMode;
  }

  // ========== 数据获取 ==========

  /**
   * 获取所有字段（扁平数组）
   */
  getFields(): Field[] {
    return [...this.fields];
  }

  /**
   * 获取指定字段
   */
  getField(id: string): Field | null {
    return this.fields.find(f => f.id === id) || null;
  }

  /**
   * 获取当前选中的字段
   */
  getSelectedField(): Field | null {
    return this.selectedId ? this.getField(this.selectedId) : null;
  }

  /**
   * 获取容器的子字段
   */
  getChildrenFields(parentId: string): Field[] {
    return this.fields.filter(f => f.parentId === parentId);
  }

  /**
   * 获取可用组件列表
   */
  getAvailableComponents(): ComponentDefinition[] {
    return [
      // 基础组件 P0
      { type: 'input', label: '输入框', icon: '📝', category: 'basic' },
      { type: 'inputNumber', label: '数字输入', icon: '🔢', category: 'basic' },
      { type: 'select', label: '下拉选择', icon: '📋', category: 'basic' },
      { type: 'datePicker', label: '日期选择', icon: '📅', category: 'basic' },
      { type: 'checkbox', label: '复选框', icon: '☑️', category: 'basic' },
      { type: 'radio', label: '单选框', icon: '⭕', category: 'basic' },
      { type: 'switch', label: '开关', icon: '🔘', category: 'basic' },
      { type: 'button', label: '按钮', icon: '🔳', category: 'basic' },

      // 重要组件 P1
      { type: 'textarea', label: '多行文本', icon: '📄', category: 'advanced' },
      { type: 'upload', label: '文件上传', icon: '📤', category: 'advanced' },
      { type: 'cascader', label: '级联选择', icon: '🔗', category: 'advanced' },
      { type: 'timePicker', label: '时间选择', icon: '⏰', category: 'advanced' },
      { type: 'rangePicker', label: '范围选择', icon: '📊', category: 'advanced' },
      { type: 'autoComplete', label: '自动完成', icon: '🔍', category: 'advanced' },
      { type: 'rate', label: '评分', icon: '⭐', category: 'advanced' },
      { type: 'tag', label: '标签', icon: '🏷️', category: 'advanced' },

      // 布局组件
      { type: 'card', label: '卡片', icon: '🗂️', category: 'layout' },
      { type: 'tabs', label: '标签页', icon: '📑', category: 'layout' },
      { type: 'collapse', label: '折叠面板', icon: '📁', category: 'layout' },
      { type: 'divider', label: '分割线', icon: '➖', category: 'layout' },

      // 高级组件 P2
      { type: 'subTable', label: '子表', icon: '📋', category: 'high-level' },
      { type: 'richText', label: '富文本', icon: '📝', category: 'high-level' },
      { type: 'tree', label: '树形控件', icon: '🌲', category: 'high-level' },
      { type: 'transfer', label: '穿梭框', icon: '⇄', category: 'high-level' },
      { type: 'slider', label: '滑块', icon: '🎚️', category: 'high-level' },
      { type: 'colorPicker', label: '颜色选择', icon: '🎨', category: 'high-level' },
      { type: 'calendar', label: '日历', icon: '📆', category: 'high-level' },
    ];
  }

  // ========== 保存/加载 ==========

  /**
   * 保存表单定义
   * 模拟：点击保存按钮
   */
  save(): FormDefinition {
    return {
      formId: 'custom_form',
      formName: '自定义表单',
      version: '1.0',
      fields: this.getFields(),
    };
  }

  /**
   * 加载表单定义
   * 模拟：打开已有表单
   */
  load(definition: FormDefinition): void {
    this.fields = [...definition.fields];
    this.selectedId = null;
  }

  /**
   * 清空画布
   */
  clear(): void {
    this.fields = [];
    this.selectedId = null;
  }

  // ========== 统计信息 ==========

  /**
   * 获取字段数量
   */
  getFieldCount(): number {
    return this.fields.length;
  }

  /**
   * 按类型统计
   */
  getFieldCountByType(): Record<string, number> {
    const counts: Record<string, number> = {};
    this.fields.forEach(f => {
      counts[f.type] = (counts[f.type] || 0) + 1;
    });
    return counts;
  }
}
