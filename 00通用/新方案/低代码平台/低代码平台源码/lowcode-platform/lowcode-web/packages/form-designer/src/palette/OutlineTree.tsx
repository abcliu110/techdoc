import React from 'react';
import { observer } from 'mobx-react-lite';
import { store } from '../store/designerStore';
import { ELEMENT_LABELS, type ElementType } from '@lowcode/shared';
import { Tree } from 'antd';
import type { DataNode } from 'antd/es/tree';

export const OutlineTree = observer(() => {
  const { formDef, selectedNodeId } = store;

  const buildTree = (nodes: any[]): DataNode[] => {
    return nodes.map(node => ({
      key: node.id || node.nodeId,
      title: (
        <span style={{ fontSize: 10, color: selectedNodeId === (node.id || node.nodeId) ? '#2563EB' : undefined }}>
          {node.label || node.type}
        </span>
      ),
      children: node.children ? buildTree(node.children) : undefined,
    }));
  };

  const treeData = buildTree(formDef.schema.children ?? []);

  return (
    <Tree
      treeData={treeData}
      selectedKeys={selectedNodeId ? [selectedNodeId] : []}
      onSelect={(keys) => store.selectNode(keys[0] as string)}
      style={{ fontSize: 10 }}
      defaultExpandAll
    />
  );
});
