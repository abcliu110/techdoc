import { makeAutoObservable, runInAction } from 'mobx';
import type {
  DesignerFieldData,
  FormDefinition,
  ViewMode,
  ValidationProblem,
  PageSchema,
  ElementType,
  LayoutControlType,
  LayoutNode,
  DragItem,
  SchemaNode,
} from '@lowcode/shared';
import { isLayoutControl } from '@lowcode/shared';
import { nanoid } from './utils/nanoid';

// 默认页面 Schema — pageRoot 直接作为根节点
function createDefaultSchema(): PageSchema {
  return {
    nodeId: 'pageRoot',
    type: 'dockContainer',
    label: '销售订单页面',
    slots: {},
    props: { leftSize: '110px', rightSize: '140px' },
    children: [],
  };
}

// ================================ 拖拽转换为节点 ================================

/** 从拖拽项创建新的 Schema 节点 */
function createNodeFromDrag(item: DragItem): SchemaNode {
  if (item.isLayout) {
    // 布局控件节点
    const node: LayoutNode = {
      id: nanoid(),
      type: item.type as LayoutControlType,
      label: item.label,
      nodeId: item.label.replace(/Layout|Container|Region|Pane|Panel|Detail$/g, '').toLowerCase() + nanoid(4),
      style: {},
      props: getDefaultLayoutProps(item.type as LayoutControlType),
      slots: {},
      visible: true,
    };
    return node;
  }
  // 业务字段节点
  const field: DesignerFieldData = {
    id: nanoid(),
    type: item.type as ElementType,
    label: item.label,
    fieldId: item.label.replace(/[^\w]/g, '').toLowerCase() + nanoid(4),
    placeholder: `请输入${item.label}`,
  };
  return field;
}

/** 获取布局控件的默认属性 */
function getDefaultLayoutProps(type: LayoutControlType): Record<string, unknown> {
  const propsMap: Record<LayoutControlType, Record<string, unknown>> = {
    gridContainer: { columns: 24, gap: '8px' },
    formGridContainer: { columns: 24, labelWidth: '78px', gap: '6px 8px' },
    flexContainer: { direction: 'row', wrap: true, gap: '8px' },
    dockContainer: { leftSize: '110px', rightSize: '140px', collapsible: true },
    splitContainer: { direction: 'horizontal', primary: '34%', resizable: true },
    scrollContainer: { overflowY: 'auto', shadow: true },
    stickyContainer: { zIndex: 100 },
    tabsContainer: { tabLabels: ['基本信息', '明细', '附件'], activeTab: 0, lazy: true },
    portalContainer: { zIndex: 1200, boundary: 'viewport' },
    responsiveContainer: { breakpoints: ['1280', '1440', '1600'], mode: 'override' },
    masterDetailContainer: { masterKey: 'id', detailLoad: 'lazy', resizable: true },
    stackContainer: { direction: 'vertical', gap: '8px' },
    accordionContainer: { mode: 'single', defaultOpen: 0 },
    cardGridContainer: { columns: 3, cardMin: '180px', rowGap: '8px' },
    drawerContainer: { placement: 'right', width: '420px', mask: false },
    dialogContainer: { modal: true, width: '600px', destroyOnClose: true },
  };
  return propsMap[type] || {};
}

class DesignerStore {
  // 表单定义
  formDef: FormDefinition = {
    id: nanoid(),
    name: '销售订单',
    revision: 1,
    type: 'bill',
    schema: createDefaultSchema(),
    draft: true,
  };

  // 选中节点
  selectedNodeId: string | null = null;
  hoveredNodeId: string | null = null;

  // 视图模式
  viewMode: ViewMode = 'design';

  // 左侧面板
  leftTab: 'palette' | 'field' | 'outline' = 'palette';

  // 右侧面板
  rightTab: 'property' | 'layout' | 'rule' = 'property';

  // 历史
  undoStack: PageSchema[] = [];
  redoStack: PageSchema[] = [];

  // 脏标记
  dirty = false;

  // 校验问题
  problems: ValidationProblem[] = [
    { id: '1', severity: 'error', code: 'P-033', message: '反审核按钮缺少岗位权限配置', category: 'permission' },
    { id: '2', severity: 'warning', code: 'L-201', message: '1280 断点下右侧信息区应折叠', category: 'layout' },
    { id: '3', severity: 'warning', code: 'B-102', message: '客户字段变更将触发价格政策重算', category: 'rule' },
  ];

  constructor() {
    makeAutoObservable(this);
  }

  // 选中节点
  selectNode(id: string | null) {
    this.selectedNodeId = id;
  }

  // 悬停节点
  hoverNode(id: string | null) {
    this.hoveredNodeId = id;
  }

  // 设置视图模式
  setViewMode(mode: ViewMode) {
    this.viewMode = mode;
  }

  // 左侧 Tab
  setLeftTab(tab: 'palette' | 'field' | 'outline') {
    this.leftTab = tab;
  }

  // 右侧 Tab
  setRightTab(tab: 'property' | 'layout' | 'rule') {
    this.rightTab = tab;
  }

  // 获取选中节点
  get selectedNode(): SchemaNode | null {
    if (!this.selectedNodeId) return null;
    return this.findNodeById(this.formDef.schema, this.selectedNodeId);
  }

  findNodeById(schema: PageSchema, id: string): SchemaNode | null {
    if (schema.nodeId === id) return schema as unknown as SchemaNode;
    if ((schema as unknown as SchemaNode).id === id) return schema as unknown as SchemaNode;
    for (const child of schema.children ?? []) {
      const found = this.findNodeById(child as unknown as PageSchema, id);
      if (found) return found;
    }
    return null;
  }

  // 添加节点到指定父节点和插槽
  addNode(parentId: string, node: SchemaNode, slotName: string = 'default', index?: number) {
    const parent = this.findNodeById(this.formDef.schema, parentId);
    if (!parent) return;

    this.pushUndo();
    // 如果父节点是 LayoutNode，添加到对应插槽
    if ('slots' in parent && parent.slots) {
      if (!parent.slots[slotName]) parent.slots[slotName] = [];
      if (index !== undefined) {
        parent.slots[slotName].splice(index, 0, node as LayoutNode);
      } else {
        parent.slots[slotName].push(node as LayoutNode);
      }
    } else if ('children' in parent) {
      // 兼容旧字段节点
      if (!parent.children) parent.children = [];
      if (index !== undefined) {
        parent.children.splice(index, 0, node);
      } else {
        parent.children.push(node);
      }
    }
    this.dirty = true;
    this.selectedNodeId = ('id' in node ? node.id : node.nodeId) as string;
  }

  // 删除节点
  removeNode(id: string) {
    const node = this.findNodeById(this.formDef.schema, id);
    if (!node) return;

    this.pushUndo();
    this.deleteNodeRecursive(this.formDef.schema, id);
    this.dirty = true;
    if (this.selectedNodeId === id) {
      this.selectedNodeId = null;
    }
  }

  private deleteNodeRecursive(schema: PageSchema, id: string): boolean {
    const children = schema.children ?? [];
    for (let i = 0; i < children.length; i++) {
      const child = children[i] as unknown as SchemaNode;
      if (child.id === id || child.nodeId === id) {
        children.splice(i, 1);
        return true;
      }
      if (this.deleteNodeRecursive(children[i] as unknown as PageSchema, id)) {
        return true;
      }
    }
    return false;
  }

  // 更新节点属性
  updateNode(id: string, patch: Partial<SchemaNode>) {
    const node = this.findNodeById(this.formDef.schema, id);
    if (!node) return;

    this.pushUndo();
    Object.assign(node, patch);
    this.dirty = true;
  }

  // 从拖拽项创建并添加节点
  addFromDrag(parentId: string, item: DragItem, slotName: string = 'default') {
    const node = createNodeFromDrag(item);
    this.addNode(parentId, node, slotName);
  }

  // 撤销
  undo() {
    if (this.undoStack.length === 0) return;
    this.redoStack.push(JSON.parse(JSON.stringify(this.formDef.schema)));
    runInAction(() => {
      this.formDef.schema = this.undoStack.pop()!;
    });
  }

  // 重做
  redo() {
    if (this.redoStack.length === 0) return;
    this.undoStack.push(JSON.parse(JSON.stringify(this.formDef.schema)));
    runInAction(() => {
      this.formDef.schema = this.redoStack.pop()!;
    });
  }

  // 保存
  save() {
    this.pushUndo();
    this.dirty = false;
    this.formDef.revision += 1;
    this.formDef.updatedTime = new Date().toISOString();
  }

  // 添加校验问题
  addProblem(problem: Omit<ValidationProblem, 'id'>) {
    this.problems.push({ ...problem, id: nanoid() });
  }

  // 清除校验问题
  clearProblems() {
    this.problems = [];
  }

  private pushUndo() {
    this.undoStack.push(JSON.parse(JSON.stringify(this.formDef.schema)));
    if (this.undoStack.length > 50) {
      this.undoStack.shift();
    }
    this.redoStack = [];
  }

  // 获取大纲树
  getOutlineTree(): OutlineNode[] {
    return this.buildOutline(this.formDef.schema);
  }

  private buildOutline(schema: PageSchema | SchemaNode): OutlineNode[] {
    const s = schema as unknown as SchemaNode;
    const self: OutlineNode = {
      id: s.id || s.nodeId,
      label: s.label || s.nodeId,
      type: s.type,
      children: [],
    };
    const pageSchema = schema as PageSchema;
    for (const child of pageSchema.children ?? []) {
      self.children!.push(...this.buildOutline(child as unknown as PageSchema));
    }
    return [self];
  }

  // 导出 Schema JSON
  exportSchema(): string {
    return JSON.stringify(this.formDef.schema, null, 2);
  }
}

export interface OutlineNode {
  id: string;
  label: string;
  type: string;
  children?: OutlineNode[];
}

export const store = new DesignerStore();
