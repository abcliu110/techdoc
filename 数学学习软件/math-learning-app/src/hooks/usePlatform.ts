import { useState, useEffect } from 'react';
import { detectPlatform } from '../platform/StorageAdapter';

type Platform = 'tauri' | 'web' | 'unknown';

/**
 * 平台特性接口
 */
export interface PlatformFeatures {
  /** 是否支持 SQLite */
  hasSqlite: boolean;
  /** 是否支持文件访问 */
  hasFileSystem: boolean;
  /** 是否支持原生通知 */
  hasNotifications: boolean;
}

/**
 * 检测当前运行平台
 */
export function usePlatform(): Platform {
  const [platform, setPlatform] = useState<Platform>('unknown');

  useEffect(() => {
    const detected = detectPlatform();
    setPlatform(detected);
  }, []);

  return platform;
}

/**
 * 获取平台特性
 */
export function getPlatformFeatures(platform: Platform): PlatformFeatures {
  switch (platform) {
    case 'tauri':
      return {
        hasSqlite: true,
        hasFileSystem: true,
        hasNotifications: true,
      };
    case 'web':
      return {
        hasSqlite: false,
        hasFileSystem: false,
        hasNotifications: false,
      };
    default:
      return {
        hasSqlite: false,
        hasFileSystem: false,
        hasNotifications: false,
      };
  }
}
