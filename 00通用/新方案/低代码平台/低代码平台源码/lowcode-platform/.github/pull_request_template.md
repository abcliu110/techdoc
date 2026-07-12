# Lowcode Platform Pull Request Checklist

## Scope

- Task card / issue:
- Changed modules:
- User-visible behavior:

## Compatibility

- [ ] Existing API fields, enum codes, error codes, and defaults are preserved.
- [ ] Metadata JSON / page schema / plugin SPI compatibility is described.
- [ ] Old runtime behavior is retained or the changed behavior is explicitly gated.
- [ ] Data migration, DDL, and rollback boundaries are listed when applicable.

## Security

- [ ] Tenant isolation is preserved; no query can run without tenant context.
- [ ] Dynamic SQL uses metadata allowlists; user input is never SQL structure.
- [ ] Permissions are enforced by the shared AccessView / runtime schema path.
- [ ] Secrets, tokens, personal data, and full SQL parameters are not logged.
- [ ] Renderer/schema changes pass XSS and dangerous-prop tests when applicable.

## Verification

- [ ] Unit tests:
- [ ] Integration tests:
- [ ] Frontend lint/test/build:
- [ ] Release gate:
- [ ] Related runbooks / checklists updated when release behavior changed.
- [ ] Covered trap IDs from `00-陷阱覆盖总表.md`:

## Rollback

- Rollback action:
- Non-rollbackable data or DDL:
- Observability / metrics to watch:
- Human confirmation required:

## Release Governance

- [ ] `docs/review/release-checklist.md` reviewed for release-impacting changes.
- [ ] Rollback threshold and watch window are explicit.
- [ ] Dependency / License / SBOM conclusion is explicit.
- [ ] `docs/compliance/release-gap-register.md` is updated when light-gate coverage is not enough for this release.

## Notes

- Remaining risks:
- Follow-up tasks:
