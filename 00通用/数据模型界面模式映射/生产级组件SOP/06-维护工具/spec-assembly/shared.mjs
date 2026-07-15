import { readFileSync } from "node:fs";
import { relative, resolve } from "node:path";

export function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

export function stableValue(value) {
  if (Array.isArray(value)) return value.map(stableValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(Object.keys(value).sort().map((key) => [key, stableValue(value[key])]));
}

export function stableJson(value) {
  return `${JSON.stringify(stableValue(value), null, 2)}\n`;
}

export function resolveInside(root, base, target, label) {
  const path = resolve(base, target);
  const relation = relative(resolve(root), path);
  if (relation.startsWith("..") || relation === "" && path !== resolve(root)) {
    throw new Error(`${label} is outside v2 root: ${target}`);
  }
  return path;
}
