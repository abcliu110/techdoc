# Browser Session and CSRF Compliance Gate

This file records the current F9 control for authentication session and CSRF risk. It is intentionally narrow because M0 does not ship Spring Security or cookie-backed browser login.

## Current boundary

- Browser session: no cookie-backed browser session is implemented in `lowcode-app`.
- Request identity: runtime HTTP requests must use signed gateway headers.
- Replay guard: `X-Gateway-Timestamp` is part of the signature payload.
- Tamper guard: `X-Gateway-Signature` covers tenant, workspace, user, roles, route, timestamp, and meta hash.
- Tenant guard: `X-Tenant-Id` is required and resolved before runtime actions.

## Machine gate

`scripts/verify-security-compliance.ps1` is called by `scripts/verify-release.ps1 -Light`.

It currently checks:

- this F9 document exists and names Browser session, CSRF, and `X-Gateway-Signature`
- `docs/compliance/README.md` links this gate
- `docs/compliance/release-gap-register.md` records the remaining `BROWSER-SESSION-CSRF` gap
- main Java code does not introduce `HttpSession`, servlet `Cookie`, `@SessionAttributes`, hard-coded `JSESSIONID`, or explicit CSRF disable calls

## Exit criteria

Close `BROWSER-SESSION-CSRF` only after browser login is implemented with a formal security configuration and tests that cover:

- CSRF attack request rejection for cookie-authenticated state-changing endpoints
- disabled-user old token or old session rejection
- cross-tenant token replay rejection
- session logout or token revocation behavior

Until then, the accepted M0 control is signed gateway headers plus a structural ban on cookie-backed server sessions in main Java code.
