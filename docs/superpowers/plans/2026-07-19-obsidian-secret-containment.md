# Obsidian Secret Containment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove reusable secrets from tracked knowledge-base files, make `obsidian_query.py` use `OBSIDIAN_API_KEY`, and provide bounded local Markdown fallback when the Local REST API is unavailable.

**Architecture:** Keep the existing single-file CLI and `requests` dependency. Add small configuration/request/fallback functions, cover them with standard-library `unittest`, ignore and untrack only local runtime state, and update the guide to the plugin's real endpoints.

**Tech Stack:** Python 3, `requests`, `unittest`, Git, Markdown, PowerShell 7.

---

### Task 1: Capture the current leak and missing fallback as failing checks

**Files:**
- Create: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/tests/test_obsidian_query.py`
- Inspect: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/obsidian_query.py`

- [ ] **Step 1: Run a tracked-file secret scan and preserve only the count**

Run from `D:/mywork/techdoc`:

```powershell
$matches = git grep -n -I -E 'BEGIN (RSA )?PRIVATE KEY|API_KEY[[:space:]]*=[[:space:]]*"[A-Fa-f0-9]{32,}"|"api_key"[[:space:]]*:[[:space:]]*"[A-Fa-f0-9]{32,}"|Authorization: Bearer [A-Za-z0-9._-]{20,}' -- '00通用/01-知识库/低代码平台竞品知识库'
if ($LASTEXITCODE -notin 0,1) { exit $LASTEXITCODE }
"tracked secret matches: $(@($matches).Count)"
if (@($matches).Count -eq 0) { exit 1 }
```

Expected: non-zero match count. Do not print `$matches` because it can contain reusable secret material.

- [ ] **Step 2: Add tests that fail cleanly before implementation**

Create `tests/test_obsidian_query.py` with this structure:

```python
import importlib.util
import os
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

MODULE_PATH = Path(__file__).resolve().parents[1] / "obsidian_query.py"
SPEC = importlib.util.spec_from_file_location("obsidian_query", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ObsidianQueryTest(unittest.TestCase):
    def test_build_headers_requires_environment_key(self):
        build_headers = getattr(MODULE, "build_headers", None)
        self.assertIsNotNone(build_headers, "build_headers must be implemented")
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "OBSIDIAN_API_KEY"):
                build_headers()

    def test_build_headers_uses_environment_key(self):
        build_headers = getattr(MODULE, "build_headers", None)
        self.assertIsNotNone(build_headers, "build_headers must be implemented")
        with patch.dict(os.environ, {"OBSIDIAN_API_KEY": "test-token"}, clear=True):
            self.assertEqual("Bearer test-token", build_headers()["Authorization"])

    def test_api_request_has_timeout_and_status_check(self):
        request_get = getattr(MODULE, "request_get", None)
        self.assertIsNotNone(request_get, "request_get must be implemented")
        response = Mock()
        response.json.return_value = {"files": []}
        with patch.dict(os.environ, {"OBSIDIAN_API_KEY": "test-token"}, clear=True):
            with patch.object(MODULE.requests, "get", return_value=response) as get:
                request_get("/vault/")
        self.assertEqual(MODULE.REQUEST_TIMEOUT_SECONDS, get.call_args.kwargs["timeout"])
        response.raise_for_status.assert_called_once_with()

    def test_search_falls_back_without_anonymous_api_call(self):
        search_notes = getattr(MODULE, "search_notes", None)
        self.assertIsNotNone(search_notes, "search_notes must be implemented")
        with patch.dict(os.environ, {}, clear=True):
            with patch.object(MODULE.requests, "get") as get:
                results = search_notes("README", max_results=2)
        get.assert_not_called()
        self.assertTrue(all(item["source"] == "local" for item in results))

    def test_source_does_not_embed_reusable_secret(self):
        source = MODULE_PATH.read_text(encoding="utf-8")
        self.assertNotRegex(source, r'API_KEY\s*=\s*"[A-Fa-f0-9]{32,}"')
        self.assertNotIn("BEGIN RSA PRIVATE KEY", source)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 3: Run the test to verify RED**

Run:

```powershell
python -m unittest discover -s tests -p 'test_*.py' -v
```

Expected: FAIL because `build_headers` and `request_get` do not exist, fallback is absent, and the source still embeds a fixed key. The command must not print the key.

### Task 2: Implement environment-only credentials and bounded local fallback

**Files:**
- Modify: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/obsidian_query.py`
- Test: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/tests/test_obsidian_query.py`

- [ ] **Step 1: Replace module-level credentials with small helpers**

Keep `API_URL` and `VERIFY_SSL`, add these definitions, and remove the fixed `API_KEY` and `HEADERS` constants:

```python
import os
from urllib.parse import quote

REQUEST_TIMEOUT_SECONDS = 5
VAULT_ROOT = Path(__file__).resolve().parent
LOCAL_EXCLUDED_DIRS = {".git", ".obsidian", "cache", "logs", ".tmp"}


def build_headers():
    api_key = os.environ.get("OBSIDIAN_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError("OBSIDIAN_API_KEY is not set")
    return {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }


def request_get(path):
    response = requests.get(
        f"{API_URL}{path}",
        headers=build_headers(),
        verify=VERIFY_SSL,
        timeout=REQUEST_TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    return response
```

- [ ] **Step 2: Route existing API functions through `request_get`**

Use the real plugin endpoints and URL-encode note paths:

```python
def get_vault_files():
    return request_get("/vault/").json()


def read_note(file_path: str):
    return request_get(f"/vault/{quote(file_path)}").text


def get_directory_files(directory: str):
    return request_get(f"/vault/{quote(directory)}").json()
```

- [ ] **Step 3: Add a limited local Markdown search**

```python
def local_markdown_files():
    for path in VAULT_ROOT.rglob("*.md"):
        if not any(part in LOCAL_EXCLUDED_DIRS for part in path.relative_to(VAULT_ROOT).parts):
            yield path


def search_local_notes(query: str, max_results: int = 10):
    results = []
    lowered = query.casefold()
    for path in local_markdown_files():
        content = path.read_text(encoding="utf-8", errors="replace")
        matches = [line for line in content.splitlines() if lowered in line.casefold()]
        if matches:
            results.append(
                {
                    "file": path.relative_to(VAULT_ROOT).as_posix(),
                    "matches": matches[:3],
                    "source": "local",
                }
            )
        if len(results) >= max_results:
            break
    return results
```

- [ ] **Step 4: Make API search fall back only on expected failures**

Preserve the existing output shape and add the source marker:

```python
def search_notes(query: str, max_results: int = 10):
    try:
        files = get_vault_files().get("files", [])
        results = []
        for file_path in files:
            if not file_path.endswith(".md"):
                continue
            content = read_note(file_path)
            matches = [line for line in content.splitlines() if query.casefold() in line.casefold()]
            if matches:
                results.append(
                    {"file": file_path, "matches": matches[:3], "source": "api"}
                )
            if len(results) >= max_results:
                break
        return results
    except (RuntimeError, requests.RequestException):
        return search_local_notes(query, max_results)
```

Update `main()` so it prints one concise line when results come from `local`, and catches `RuntimeError` / `requests.RequestException` for `--list` and `--read` without printing a traceback or headers.

- [ ] **Step 5: Run the tests to verify GREEN**

Run:

```powershell
python -m unittest discover -s tests -p 'test_*.py' -v
```

Expected: all tests pass, with no real credential in stdout.

### Task 3: Stop tracking runtime secrets while preserving local files

**Files:**
- Modify: `D:/mywork/techdoc/.gitignore`
- Preserve locally but untrack:
  - `00通用/01-知识库/低代码平台竞品知识库/.obsidian/api-config.json`
  - `00通用/01-知识库/低代码平台竞品知识库/.obsidian/workspace.json`
  - `00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/obsidian-local-rest-api/data.json`
  - `00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/smart-connections/data.json`

- [ ] **Step 1: Add narrow ignore rules**

Append only these knowledge-base-specific patterns:

```gitignore
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/api-config.json
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/workspace*.json
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/*/data.json
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/**/*.pem
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/**/*.key
/00通用/01-知识库/低代码平台竞品知识库/.obsidian/**/*.crt
```

- [ ] **Step 2: Untrack the four runtime files without deleting local copies**

First verify all resolved paths stay under the knowledge-base `.obsidian` directory, then run:

```powershell
git rm --cached -- '00通用/01-知识库/低代码平台竞品知识库/.obsidian/api-config.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/workspace.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/obsidian-local-rest-api/data.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/smart-connections/data.json'
```

Expected: index deletions are staged; all four local files still pass `Test-Path`.

- [ ] **Step 3: Verify ignore and tracking state**

Run:

```powershell
git check-ignore -v -- '00通用/01-知识库/低代码平台竞品知识库/.obsidian/api-config.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/workspace.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/obsidian-local-rest-api/data.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/smart-connections/data.json'
git ls-files -- '00通用/01-知识库/低代码平台竞品知识库/.obsidian/api-config.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/workspace.json' '00通用/01-知识库/低代码平台竞品知识库/.obsidian/plugins/*/data.json'
```

Expected: `git check-ignore` lists all four; `git ls-files` prints nothing.

### Task 4: Remove credential templates and correct the usage guide

**Files:**
- Modify: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/insert_config.py`
- Modify: `D:/mywork/techdoc/00通用/01-知识库/低代码平台竞品知识库/OBSIDIAN使用指南.md`

- [ ] **Step 1: Preserve the user's corrected vault path**

Before editing, run exact diffs for both files. Keep the existing `00通用/01-知识库/...` path change in `insert_config.py`; only change credential and command text.

- [ ] **Step 2: Replace fixed credential text in `insert_config.py`**

The generated table must say:

```markdown
| API Key | 通过环境变量 `OBSIDIAN_API_KEY` 提供，禁止写入规则文件或源码 |
```

Replace Bash curl examples with the existing PowerShell pattern:

```powershell
$headers = @{ Authorization = "Bearer $env:OBSIDIAN_API_KEY" }
Invoke-RestMethod -SkipCertificateCheck -Headers $headers -Uri 'https://127.0.0.1:27124/vault/'
```

- [ ] **Step 3: Replace obsolete guide endpoints**

Document only these installed-plugin endpoints:

```text
GET  /vault/
GET  /vault/{文件路径}
POST /search/
POST /search/simple/
```

State that `obsidian_query.py` reads `OBSIDIAN_API_KEY`, uses a five-second request timeout, and falls back to local read-only Markdown search when the API cannot be reached.

- [ ] **Step 4: Re-run tests and the tracked-file secret scan**

Run the Task 1 unittest command and secret scan again.

Expected: tests pass; tracked secret match count is zero; no private key or token is printed.

- [ ] **Step 5: Record external actions that remain mandatory**

In the final handoff, list these as human-coordinated actions, not completed work:

```text
1. Rotate the exposed Obsidian Local REST API key.
2. Regenerate the local TLS certificate and private key.
3. Decide whether to rewrite repository history from commit 5927500 onward.
4. Coordinate any history rewrite and force-push with all repository users.
```

Do not rewrite history, rotate credentials, or push a remote branch in this plan.

