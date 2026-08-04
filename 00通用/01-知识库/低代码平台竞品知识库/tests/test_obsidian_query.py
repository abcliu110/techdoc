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
            with patch.object(MODULE, "search_local_notes", return_value=[{"source": "local"}]) as local:
                with patch.object(MODULE.requests, "get") as get:
                    results = search_notes("README", max_results=2)
        get.assert_not_called()
        local.assert_called_once_with("README", 2)
        self.assertEqual([{"source": "local"}], results)

    def test_search_does_not_hide_http_authentication_errors(self):
        search_notes = getattr(MODULE, "search_notes", None)
        response = Mock()
        response.raise_for_status.side_effect = MODULE.requests.HTTPError("401")
        with patch.dict(os.environ, {"OBSIDIAN_API_KEY": "test-token"}, clear=True):
            with patch.object(MODULE.requests, "get", return_value=response):
                with patch.object(MODULE, "search_local_notes") as local:
                    with self.assertRaises(MODULE.requests.HTTPError):
                        search_notes("README", max_results=2)
        local.assert_not_called()

    def test_search_records_local_source_when_no_notes_match(self):
        search_notes = getattr(MODULE, "search_notes", None)
        with patch.dict(os.environ, {}, clear=True):
            with patch.object(MODULE, "search_local_notes", return_value=[]):
                self.assertEqual([], search_notes("not-found", max_results=2))
        self.assertEqual("local", MODULE.LAST_SEARCH_SOURCE)

    def test_source_does_not_embed_reusable_secret(self):
        source = MODULE_PATH.read_text(encoding="utf-8")
        self.assertNotRegex(source, r'API_KEY\s*=\s*"[A-Fa-f0-9]{32,}"')
        private_key_marker = "BEGIN " + "RSA PRIVATE KEY"
        self.assertNotIn(private_key_marker, source)


if __name__ == "__main__":
    unittest.main()
