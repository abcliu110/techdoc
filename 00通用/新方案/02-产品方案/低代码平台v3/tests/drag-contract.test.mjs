import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const app = await readFile(new URL('../prototype/app.js', import.meta.url), 'utf8');
const html = await readFile(new URL('../prototype/index.html', import.meta.url), 'utf8');

test('UI routes material and node drops through the Schema engine', () => {
  assert.match(app, /import\s*\{[^}]*insertMaterial[^}]*moveNode[^}]*\}\s*from '\.\/schema-engine\.mjs(?:\?[^']+)?'/s);
  assert.match(app, /insertMaterial\(state\.schema/);
  assert.match(app, /moveNode\(state\.schema/);
  assert.match(app, /applySchemaTransaction/);
  assert.match(app, /application\/x-lowcode-node/);
  assert.match(app, /position:\s*dropPosition/);
});

test('rendered workbench exposes authoritative Schema evidence hooks', () => {
  assert.match(html, /data-testid="schema-node-count"/);
  assert.match(html, /data-testid="schema-json"/);
  assert.match(html, /data-testid="drop-result"/);
  assert.match(app, /dataset\.schemaNode/);
  assert.match(app, /draggable="true"/);
});

test('keyboard users have add and move commands', () => {
  assert.match(app, /data-keyboard-add/);
  assert.match(app, /data-move-command/);
  assert.match(app, /move-up|move-down|move-in|move-out/);
});

test('initial header fields expose the same drag and move protocol as added schema fields', () => {
  assert.match(app, /data-header-schema-field[^>]*data-schema-node="\$\{node\.id\}"[^>]*data-schema-drop-target="\$\{node\.id\}"/);
  assert.match(app, /data-header-schema-field[\s\S]*?\$\{moveCommands\(\)\}/);
  assert.match(app, /role="button"[^>]*tabindex="0"[^>]*draggable="true"[^>]*data-header-schema-field/);
});
