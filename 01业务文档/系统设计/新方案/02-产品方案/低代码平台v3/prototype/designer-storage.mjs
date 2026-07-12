export const DESIGNER_STORAGE_VERSION = 1;
export const DESIGNER_STORAGE_KEY = 'lowcode-designer-v3';
export const WORKSPACE_STORAGE_KEY = 'lowcode-designer-v3-workspaces';

export function encodeDesignerSnapshot(state) {
  return JSON.stringify({
    storageVersion: DESIGNER_STORAGE_VERSION,
    savedAt: new Date().toISOString(),
    schema: structuredClone(state.schema),
    device: state.device,
    businessState: state.businessState,
  });
}

export function decodeDesignerSnapshot(source) {
  let snapshot;
  try {
    snapshot = typeof source === 'string' ? JSON.parse(source) : structuredClone(source);
  } catch {
    throw new Error('无法解析设计器快照');
  }
  if (snapshot?.storageVersion !== DESIGNER_STORAGE_VERSION) {
    throw new Error(`不支持的设计器快照版本：${snapshot?.storageVersion ?? 'missing'}`);
  }
  if (!snapshot.schema?.rootId || !snapshot.schema?.nodes) throw new Error('设计器快照缺少 Schema');
  return structuredClone(snapshot);
}

export function encodeWorkspaceSnapshot(value) {
  return JSON.stringify({ storageVersion: 1, savedAt: new Date().toISOString(), value: structuredClone(value) });
}

export function createWorkspaceSnapshotValue(value) {
  return {
    businessModelState: value.businessModelState,
    ruleBuilderState: value.ruleBuilderState,
    permissionMatrixState: value.permissionMatrixState,
    commandState: value.commandState,
    entryColumns: value.entryColumns,
    selectedComponentType: value.selectedComponentType,
    componentRuntimeStates: value.componentRuntimeStates instanceof Map
      ? [...value.componentRuntimeStates.entries()]
      : value.componentRuntimeStates,
    previewData: value.previewData,
    previewSample: value.previewSample,
    previewDevice: value.previewDevice,
  };
}

export function decodeWorkspaceSnapshot(source) {
  let snapshot;
  try { snapshot = typeof source === 'string' ? JSON.parse(source) : structuredClone(source); }
  catch { throw new Error('无法解析工作区快照'); }
  if (snapshot?.storageVersion !== 1 || !snapshot.value) throw new Error('不支持的工作区快照');
  return structuredClone(snapshot.value);
}
