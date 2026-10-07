import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock Dexie for tests
vi.mock('dexie', () => {
  const mockDexie = {
    open: vi.fn().mockResolvedValue(undefined),
    sessions: {
      put: vi.fn().mockResolvedValue(undefined),
      get: vi.fn().mockResolvedValue(null),
      toArray: vi.fn().mockResolvedValue([]),
      where: vi.fn().mockReturnValue({
        anyOf: vi.fn().mockReturnValue({
          first: vi.fn().mockResolvedValue(null),
        }),
        equals: vi.fn().mockReturnValue({
          toArray: vi.fn().mockResolvedValue([]),
        }),
      }),
      delete: vi.fn().mockResolvedValue(undefined),
    },
    evidence: {
      put: vi.fn().mockResolvedValue(undefined),
      where: vi.fn().mockReturnValue({
        equals: vi.fn().mockReturnValue({
          toArray: vi.fn().mockResolvedValue([]),
        }),
      }),
    },
    profiles: {
      put: vi.fn().mockResolvedValue(undefined),
      get: vi.fn().mockResolvedValue(null),
      delete: vi.fn().mockResolvedValue(undefined),
    },
  };

  return {
    default: vi.fn(() => mockDexie),
  };
});

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});
