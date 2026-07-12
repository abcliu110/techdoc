# Formal OpenAPI / License / SBOM Toolchain Migration

## Goal

The current release compliance gate is intentionally lightweight and repository-native:

- route-level OpenAPI drift detection
- reviewed committed License inventory for direct dependencies and Docker images
- minimal SBOM for Java modules, workspace packages, direct dependencies, and images

This document defines the migration path to a formal production toolchain without changing the current repository dependency set yet.

## Cutover principles

1. Keep the current light gate blocking until a formal replacement has shadow evidence.
2. Migrate OpenAPI, License, and SBOM independently; do not force a single big-bang switch.
3. For at least two release candidates, run the formal toolchain in shadow mode and compare its output with the committed baselines.
4. Record every mismatch or capability gap in `docs/compliance/release-gap-register.md` before making the formal toolchain blocking.

## OpenAPI migration

### Current state

- Blocking scope: controller route drift only.
- Missing scope: DTO field-level diff, enum change diff, response/request schema breaking change classification.

### Migration steps

1. Define the canonical `openapi.json` generation entry for `lowcode-app`.
2. Store the released spec artifact per tag or release candidate.
3. Add automated diff classification for additive vs. breaking changes.
4. Shadow the formal diff alongside `docs/compliance/openapi-http-baseline.txt`.
5. After two clean shadow releases, switch the blocking rule from route-only drift to formal spec diff, and keep the route baseline as a fallback sanity check.

## License migration

### Current state

- Blocking scope: Maven direct dependencies, pnpm direct dependencies, Docker images.
- Missing scope: transitive dependencies, normalized legal metadata, exception workflows, artifact provenance.

### Migration steps

1. Choose the approved legal/compliance scanner when policy allows new tooling.
2. Generate a normalized dependency inventory for Maven, pnpm lock resolution, and container images.
3. Add policy mapping for approved / denied / manual-review licenses.
4. Shadow the scanner output against `docs/compliance/license-inventory.json`.
5. Once scanner output is stable, replace manual direct-dependency inventory blocking with scanner-backed blocking and preserve the committed inventory as an emergency fallback.

## SBOM migration

### Current state

- Blocking scope: release composition drift for modules, workspace packages, direct dependencies, and Docker images.
- Missing scope: standard SBOM format, hashes, purl, supplier, transitive dependency graph, artifact attachment to release bundles.

### Migration steps

1. Generate a standard CycloneDX or SPDX artifact in CI.
2. Include package URL, version, supplier, and checksum fields.
3. Publish the SBOM artifact with the release candidate or CI evidence bundle.
4. Shadow-compare the formal SBOM against `docs/compliance/sbom-minimal.json`.
5. Promote the formal SBOM artifact to the blocking source after shadow parity is stable.

## Release cutover checklist

- Formal OpenAPI diff has shadow evidence for at least two release candidates.
- Formal License scan has reviewed policy mapping and no unresolved `UNREVIEWED` equivalent.
- Formal SBOM artifact is attached to CI/release outputs and can be reproduced locally.
- `docs/review/release-checklist.md` points to the new evidence location.
- `docs/compliance/release-gap-register.md` marks the corresponding gaps as closed.

## Current limitation

Until the cutover is complete, this repository must continue to describe the release compliance gate as a light gate rather than a fully production-grade formal compliance toolchain.
