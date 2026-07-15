import { existsSync, readFileSync } from "node:fs";
import { isAbsolute, relative, resolve } from "node:path";

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
  if (isAbsolute(relation) || relation.startsWith("..")) {
    throw new Error(`${label} is outside v2 root: ${target}`);
  }
  return path;
}

export function escapePointerToken(value) {
  return String(value).replaceAll("~", "~0").replaceAll("/", "~1");
}

export function getPointer(document, pointer) {
  if (pointer === "") return { exists: true, value: document };
  if (typeof pointer !== "string" || !pointer.startsWith("/")) return { exists: false };
  let value = document;
  for (const rawToken of pointer.slice(1).split("/")) {
    const token = rawToken.replaceAll("~1", "/").replaceAll("~0", "~");
    if (!value || typeof value !== "object" || !Object.prototype.hasOwnProperty.call(value, token)) return { exists: false };
    value = value[token];
  }
  return { exists: true, value };
}

export function requireFile(path, label) {
  if (!existsSync(path)) throw new Error(`${label} does not exist: ${path}`);
  return path;
}
