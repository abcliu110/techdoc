import { describe, it, expect } from 'vitest';
import { arrayToTree, treeToArray, findNode, insertNode, removeNode, isContainerComponent } from '../treeUtils';

describe('treeUtils - 树形结构工具', () => {
  const flatFields = [
    { id: '1', fieldId: 'field1', label: '字段1', type: 'input', parentId: null },
    { id: '2', fieldId: 'field2', label: '字段2', type: 'card', parentId: null },
    { id: '3', fieldId: 'field3', label: '字段3', type: 'input', parentId: '2' },
    { id: '4', fieldId: 'field4', label: '字段4', type: 'select', parentId: '2' },
  ];

  describe('arrayToTree', () => {
    it('应该将扁平数组转换为树形结构', () => {
      const tree = arrayToTree(flatFields);

      expect(tree.length).toBe(2); // 两个根节点
      expect(tree[0].id).toBe('1');
      expect(tree[1].id).toBe('2');
      expect(tree[1].children).toHaveLength(2); // card有2个子节点
    });

    it('空数组应该返回空树', () => {
      const tree = arrayToTree([]);
      expect(tree).toEqual([]);
    });
  });

  describe('treeToArray', () => {
    it('应该将树形结构转换为扁平数组', () => {
      const tree = arrayToTree(flatFields);
      const flat = treeToArray(tree);

      expect(flat.length).toBe(4);
      expect(flat.map(f => f.id)).toEqual(['1', '2', '3', '4']);
    });
  });

  describe('findNode', () => {
    it('应该能找到根节点', () => {
      const tree = arrayToTree(flatFields);
      const node = findNode(tree, '1');

      expect(node).toBeDefined();
      expect(node?.label).toBe('字段1');
    });

    it('应该能找到嵌套节点', () => {
      const tree = arrayToTree(flatFields);
      const node = findNode(tree, '3');

      expect(node).toBeDefined();
      expect(node?.label).toBe('字段3');
      expect(node?.parentId).toBe('2');
    });

    it('找不到节点应该返回null', () => {
      const tree = arrayToTree(flatFields);
      const node = findNode(tree, '999');

      expect(node).toBeNull();
    });
  });

  describe('isContainerComponent', () => {
    it('card应该是容器组件', () => {
      expect(isContainerComponent('card')).toBe(true);
    });

    it('tabs应该是容器组件', () => {
      expect(isContainerComponent('tabs')).toBe(true);
    });

    it('collapse应该是容器组件', () => {
      expect(isContainerComponent('collapse')).toBe(true);
    });

    it('input不应该是容器组件', () => {
      expect(isContainerComponent('input')).toBe(false);
    });
  });

  describe('insertNode', () => {
    it('应该能插入根节点', () => {
      const tree = arrayToTree(flatFields);
      const newNode = { id: '5', fieldId: 'field5', label: '新字段', type: 'input' };
      const newTree = insertNode(tree, newNode);

      expect(newTree.length).toBe(3);
      expect(newTree[2].id).toBe('5');
    });

    it('应该能插入子节点', () => {
      const tree = arrayToTree(flatFields);
      const newNode = { id: '5', fieldId: 'field5', label: '新字段', type: 'input' };
      const newTree = insertNode(tree, newNode, '2');

      const cardNode = findNode(newTree, '2');
      expect(cardNode?.children).toHaveLength(3);
    });
  });

  describe('removeNode', () => {
    it('应该能删除根节点', () => {
      const tree = arrayToTree(flatFields);
      const newTree = removeNode(tree, '1');

      expect(newTree.length).toBe(1);
      expect(findNode(newTree, '1')).toBeNull();
    });

    it('应该能删除嵌套节点', () => {
      const tree = arrayToTree(flatFields);
      const newTree = removeNode(tree, '3');

      const cardNode = findNode(newTree, '2');
      expect(cardNode?.children).toHaveLength(1);
    });
  });
});
