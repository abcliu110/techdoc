/**
 * 领域错误基类
 */
export class DomainError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'DomainError';
  }
}

/**
 * 会话错误
 */
export class SessionError extends DomainError {
  constructor(message: string) {
    super(message);
    this.name = 'SessionError';
  }
}

/**
 * 内容错误
 */
export class ContentError extends DomainError {
  constructor(message: string) {
    super(message);
    this.name = 'ContentError';
  }
}

/**
 * 验证错误
 */
export class ValidationError extends DomainError {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}
