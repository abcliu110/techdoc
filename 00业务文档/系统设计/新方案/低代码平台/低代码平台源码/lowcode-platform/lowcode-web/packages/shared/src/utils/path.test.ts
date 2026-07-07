import { describe, it, expect } from 'vitest';
import { getIn, setIn, deleteIn, hasIn } from './path';

describe('Path Utils', () => {
  describe('getIn', () => {
    it('should get nested object value', () => {
      const obj = { user: { address: { city: 'Beijing' } } };
      expect(getIn(obj, 'user.address.city')).toBe('Beijing');
    });

    it('should get array element', () => {
      const obj = { items: [{ name: 'A' }, { name: 'B' }] };
      expect(getIn(obj, 'items[1].name')).toBe('B');
      expect(getIn(obj, 'items.1.name')).toBe('B');
    });

    it('should return default value for non-existent path', () => {
      const obj = { user: {} };
      expect(getIn(obj, 'user.address.city', 'Unknown')).toBe('Unknown');
    });

    it('should handle null and undefined', () => {
      expect(getIn(null, 'a.b.c')).toBeUndefined();
      expect(getIn(undefined, 'a.b.c', 'default')).toBe('default');
    });

    it('should handle deep nesting', () => {
      const obj = { a: { b: { c: { d: { e: 'deep' } } } } };
      expect(getIn(obj, 'a.b.c.d.e')).toBe('deep');
    });

    it('should handle array path', () => {
      const obj = { user: { name: 'John' } };
      expect(getIn(obj, ['user', 'name'])).toBe('John');
    });
  });

  describe('setIn', () => {
    it('should set nested object value', () => {
      const obj = { user: {} } as any;
      setIn(obj, 'user.address.city', 'Shanghai');
      expect(obj.user.address.city).toBe('Shanghai');
    });

    it('should create intermediate objects', () => {
      const obj = {} as any;
      setIn(obj, 'a.b.c', 123);
      expect(obj).toEqual({ a: { b: { c: 123 } } });
    });

    it('should create arrays for numeric keys', () => {
      const obj = {} as any;
      setIn(obj, 'items[0].name', 'First');
      expect(obj.items[0].name).toBe('First');
    });

    it('should handle existing values', () => {
      const obj = { user: { name: 'John' } } as any;
      setIn(obj, 'user.age', 30);
      expect(obj).toEqual({ user: { name: 'John', age: 30 } });
    });

    it('should handle array indices', () => {
      const obj = { items: [{ id: 1 }, { id: 2 }] } as any;
      setIn(obj, 'items[1].name', 'Second');
      expect(obj.items[1]).toEqual({ id: 2, name: 'Second' });
    });

    it('should handle array path', () => {
      const obj = {} as any;
      setIn(obj, ['user', 'name'], 'Alice');
      expect(obj.user.name).toBe('Alice');
    });
  });

  describe('deleteIn', () => {
    it('should delete nested property', () => {
      const obj = { user: { name: 'John', age: 30 } };
      deleteIn(obj, 'user.age');
      expect(obj).toEqual({ user: { name: 'John' } });
    });

    it('should delete array element', () => {
      const obj = { items: ['A', 'B', 'C'] };
      deleteIn(obj, 'items[1]');
      expect(obj.items).toEqual(['A', 'C']);
    });

    it('should handle non-existent path gracefully', () => {
      const obj = { user: { name: 'John' } };
      deleteIn(obj, 'user.address.city');
      expect(obj).toEqual({ user: { name: 'John' } });
    });

    it('should handle array path', () => {
      const obj = { user: { name: 'John', age: 30 } };
      deleteIn(obj, ['user', 'age']);
      expect(obj).toEqual({ user: { name: 'John' } });
    });
  });

  describe('hasIn', () => {
    it('should return true for existing path', () => {
      const obj = { user: { address: { city: 'Beijing' } } };
      expect(hasIn(obj, 'user.address.city')).toBe(true);
    });

    it('should return false for non-existent path', () => {
      const obj = { user: {} };
      expect(hasIn(obj, 'user.address.city')).toBe(false);
    });

    it('should return false for null values in path', () => {
      const obj = { user: null };
      expect(hasIn(obj, 'user.name')).toBe(false);
    });

    it('should handle array path', () => {
      const obj = { user: { name: 'John' } };
      expect(hasIn(obj, ['user', 'name'])).toBe(true);
      expect(hasIn(obj, ['user', 'age'])).toBe(false);
    });

    it('should return true for value that is undefined', () => {
      const obj = { user: { name: undefined } };
      expect(hasIn(obj, 'user.name')).toBe(true);
    });
  });
});
