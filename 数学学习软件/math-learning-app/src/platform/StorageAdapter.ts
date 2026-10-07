/**
 * 存储适配器接口
 * 抽象 Tauri (SQLite) 和 Web (Dexie) 的差异
 */
export interface StorageAdapter {
  /**
   * 初始化存储
   */
  initialize(): Promise<void>;

  /**
   * 读取数据
   */
  read<T>(key: string): Promise<T | null>;

  /**
   * 写入数据
   */
  write<T>(key: string, value: T): Promise<void>;

  /**
   * 删除数据
   */
  delete(key: string): Promise<void>;

  /**
   * 查询数据
   */
  query<T>(table: string, filter?: Record<string, unknown>): Promise<T[]>;

  /**
   * 批量写入
   */
  batchWrite(operations: StorageOperation[]): Promise<void>;
}

/**
 * 存储操作
 */
export interface StorageOperation {
  type: 'write' | 'delete';
  key: string;
  value?: unknown;
}

/**
 * 检测当前平台
 */
export function detectPlatform(): 'tauri' | 'web' {
  if (typeof window !== 'undefined' && '__TAURI__' in window) {
    return 'tauri';
  }
  return 'web';
}
