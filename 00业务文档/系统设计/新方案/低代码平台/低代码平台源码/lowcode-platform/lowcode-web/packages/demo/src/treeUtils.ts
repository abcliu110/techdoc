/**
 * 表单字段树形结构工具函数
 */

export interface FieldNode {
  id: string;
  fieldId: string;
  label: string;
  type: string;
  parentId?: string | null;
  children?: FieldNode[];
  // 其他属性
  [key: string]: any;
}

/**
 * 将扁平数组转换为树形结构
 */
export function arrayToTree(fields: FieldNode[]): FieldNode[] {
  const map = new Map<string, FieldNode>();
  const roots: FieldNode[] = [];

  // 第一遍：创建映射
  fields.forEach(field => {
    map.set(field.id, { ...field, children: [] });
  });

  // 第二遍：建立父子关系
  fields.forEach(field => {
    const node = map.get(field.id)!;
    if (field.parentId) {
      const parent = map.get(field.parentId);
      if (parent) {
        parent.children = parent.children || [];
        parent.children.push(node);
      } else {
        roots.push(node);
      }
    } else {
      roots.push(node);
    }
  });

  return roots;
}

/**
 * 将树形结构转换为扁平数组
 */
export function treeToArray(tree: FieldNode[]): FieldNode[] {
  const result: FieldNode[] = [];

  function traverse(nodes: FieldNode[]) {
    nodes.forEach(node => {
      const { children, ...rest } = node;
      result.push(rest);
      if (children && children.length > 0) {
        traverse(children);
      }
    });
  }

  traverse(tree);
  return result;
}

/**
 * 查找节点
 */
export function findNode(tree: FieldNode[], id: string): FieldNode | null {
  for (const node of tree) {
    if (node.id === id) {
      return node;
    }
    if (node.children) {
      const found = findNode(node.children, id);
      if (found) return found;
    }
  }
  return null;
}

/**
 * 判断是否为容器组件
 */
export function isContainerComponent(type: string): boolean {
  return ['card', 'tabs', 'collapse'].includes(type);
}

/**
 * 在树中插入节点
 */
export function insertNode(
  tree: FieldNode[],
  newNode: FieldNode,
  parentId?: string | null,
  index?: number
): FieldNode[] {
  if (!parentId) {
    // 插入根节点
    const newTree = [...tree];
    if (index !== undefined) {
      newTree.splice(index, 0, newNode);
    } else {
      newTree.push(newNode);
    }
    return newTree;
  }

  // 插入子节点
  function insert(nodes: FieldNode[]): FieldNode[] {
    return nodes.map(node => {
      if (node.id === parentId) {
        const children = [...(node.children || [])];
        if (index !== undefined) {
          children.splice(index, 0, newNode);
        } else {
          children.push(newNode);
        }
        return { ...node, children };
      }
      if (node.children) {
        return { ...node, children: insert(node.children) };
      }
      return node;
    });
  }

  return insert(tree);
}

/**
 * 从树中删除节点
 */
export function removeNode(tree: FieldNode[], id: string): FieldNode[] {
  return tree
    .filter(node => node.id !== id)
    .map(node => ({
      ...node,
      children: node.children ? removeNode(node.children, id) : undefined,
    }));
}

/**
 * 移动节点到新位置
 */
export function moveNode(
  tree: FieldNode[],
  nodeId: string,
  targetParentId: string | null,
  targetIndex: number
): FieldNode[] {
  // 1. 找到并移除原节点
  let movedNode: FieldNode | null = null;

  function findAndRemove(nodes: FieldNode[]): FieldNode[] {
    return nodes.filter(node => {
      if (node.id === nodeId) {
        movedNode = node;
        return false;
      }
      if (node.children) {
        node.children = findAndRemove(node.children);
      }
      return true;
    });
  }

  let newTree = findAndRemove([...tree]);

  if (!movedNode) return tree;

  // 2. 插入到新位置
  return insertNode(newTree, movedNode, targetParentId, targetIndex);
}
