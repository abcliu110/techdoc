import type { SessionRepository, ProfileRepository, ContentRepository } from '../shared/interfaces';
import { TauriSqliteSessionRepository, TauriSqliteProfileRepository } from './tauri';
import { DexieSessionRepository, DexieProfileRepository } from './web';
import { FileSystemContentRepository } from './content/FileSystemContentRepository';
import { detectPlatform } from './StorageAdapter';

/**
 * 平台配置
 */
export interface PlatformConfig {
  sessionRepo: SessionRepository;
  profileRepo: ProfileRepository;
  contentRepo: ContentRepository;
}

/**
 * 创建 Web 平台配置
 */
export function createWebPlatform(): PlatformConfig {
  return {
    sessionRepo: new DexieSessionRepository(),
    profileRepo: new DexieProfileRepository(),
    contentRepo: new FileSystemContentRepository(),
  };
}

/**
 * 创建 Tauri 平台配置
 */
export async function createTauriPlatform(): Promise<PlatformConfig> {
  const sessionRepo = new TauriSqliteSessionRepository();
  await sessionRepo.initialize();

  const profileRepo = new TauriSqliteProfileRepository();
  await profileRepo.initialize();

  return {
    sessionRepo,
    profileRepo,
    contentRepo: new FileSystemContentRepository(),
  };
}

/**
 * 创建平台配置（根据当前环境自动选择）
 */
export async function createPlatformConfig(): Promise<PlatformConfig> {
  const platform = detectPlatform();
  if (platform === 'tauri') {
    return createTauriPlatform();
  }
  return createWebPlatform();
}

// 导出平台检测函数
export { detectPlatform } from './StorageAdapter';
export type { StorageAdapter, StorageOperation } from './StorageAdapter';
