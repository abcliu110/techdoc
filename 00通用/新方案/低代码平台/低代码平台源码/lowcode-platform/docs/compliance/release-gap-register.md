# Release Compliance Gap Register

This register captures the remaining release-compliance gaps that are still outside the current light gate coverage. Update it when a release depends on manual review beyond what `verify-release.ps1 -Light` can prove.

## Current gaps

| Gap ID | Current limitation | Evidence signal | Current control | Release-time action | Exit criteria |
|---|---|---|---|---|---|
| OPENAPI-FIELD-DIFF | Route drift is blocked, but DTO field-level and enum-level breaking changes are not auto-diffed. | Controller routes are unchanged, but request/response contract changed. | `docs/compliance/openapi-http-baseline.txt` + release checklist manual review. | Record the contract risk in `docs/review/release-checklist.md` and keep release notes explicit. | Formal `openapi.json` generation and breaking-change diff become blocking. |
| LICENSE-TRANSITIVE | License gate covers direct Maven dependencies, direct external pnpm workspace dependencies, and Docker images, but not transitive dependencies. | Direct dependency inventory is unchanged, but lock resolution or transitive graph changed. | `docs/compliance/license-inventory.json` + dependency admission review. | Block if legal review is unknown; otherwise note the manual review scope in the release checklist. | Formal dependency scanner covers transitive dependencies with reviewed policy mapping. |
| SBOM-STANDARD | The committed SBOM is minimal and non-standard; it omits hashes, purl, supplier, and full transitive graph. | Release asks for standard SBOM export or downstream supply-chain attestation. | `docs/compliance/sbom-minimal.json` + release runbook disclosure. | State the limitation in release materials and attach alternative evidence if required by delivery. | CycloneDX or SPDX artifact is generated and attached in CI. |
| BROWSER-SESSION-CSRF | F9 browser session and CSRF protection is not fully testable until browser login is implemented. | Main Java introduces cookie-backed session code, Spring Security config, or explicit CSRF disable calls. | `docs/compliance/browser-session-csrf.md` + `scripts/verify-security-compliance.ps1` structural scan. | Keep state-changing browser endpoints behind signed gateway headers and record any temporary exception here. | Formal browser session security config and CSRF tests become blocking. |

## Update rule

Update this register when:

- a release intentionally relies on manual review outside the light gate
- a new compliance limitation is discovered during release verification
- a formal toolchain milestone closes one of the gaps above
