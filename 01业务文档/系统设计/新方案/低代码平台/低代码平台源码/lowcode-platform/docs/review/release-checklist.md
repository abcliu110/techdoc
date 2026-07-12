# Release Checklist Template

用于发布前的人工确认。该清单不替代 `verify-release.ps1`，而是把发布治理、观测、回滚和合规结论写成可复核记录。

## Change Summary

- Release candidate / tag:
- Task card / issue:
- Covered trap IDs:
- Changed modules / docs:
- Feature flags or gated behavior:

## Gate Evidence

- [ ] `powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -SelfCheck`
- [ ] `powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light`
- [ ] Full backend / frontend verification evidence is linked when this release includes executable changes.
- [ ] Relevant runbooks were reviewed and updated when release behavior changed.

## Rollback

- Metadata rollback action:
- Non-rollbackable DDL or data:
- Stop-loss condition:
- Human confirmation required:

## Observability

- Metrics / alerts to watch:
- traceId / log entry points:
- Watch window and owner:
- Rollback threshold:

## Dependency / License / SBOM

- Dependency delta:
- `docs/compliance/dependency-admission.md` reviewed:
- `docs/compliance/license-sbom.md` reviewed:
- `docs/compliance/release-gap-register.md` updated or explicitly not needed:
- `docs/compliance/formal-toolchain-migration.md` follow-up needed:
- Inventory / SBOM update required:
- Private deployment / offline license impact:

## Sign-off

- Release owner:
- Ops on call:
- Security / compliance reviewer:
- Remaining risks:
