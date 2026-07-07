---
id: E-NOCOBASE-SRC-102
type: evidence
competitor: NocoBase
module: extension-migration
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/develop/packages/core/server/src/plugin-manager/plugin-manager.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# Evidence: NocoBase plugin remove

## Source location

- Repository file: $RepoPath
- Local file: $LocalFile
- Version: GitHub develop/main source as captured on 2026-07-05
- Line: L737
- Anchor pattern: $Pattern

## Observation

PluginManager.remove deletes plugin repository records and optionally removes plugin files.

## Evidence strength

Direct fact. The source file contains the referenced symbol or field at the cited line.