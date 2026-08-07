import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def load_module(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


browser_regression = load_module("browser_regression", "browser-regression.py")
responsive_audit = load_module("responsive_audit", "responsive-audit.py")


class BrowserContractAssertions(unittest.TestCase):
    def test_semantic_and_exact_state_assertions(self):
        self.assertTrue(browser_regression.state_matches("changed", "initial", "not:initial"))
        self.assertFalse(browser_regression.state_matches("initial", "initial", "not:initial"))
        self.assertTrue(browser_regression.state_matches("exact:value", "initial", "exact:value"))
        self.assertFalse(browser_regression.state_matches("wrong:value", "initial", "exact:value"))
        self.assertTrue(browser_regression.state_matches("initial-state", "initial-state", "initial"))


class ResponsiveReachabilityAssertions(unittest.TestCase):
    def test_scroll_end_requires_real_overflow_and_reachable_end(self):
        self.assertTrue(responsive_audit.scroll_reaches_end(300, 600, 300))
        self.assertFalse(responsive_audit.scroll_reaches_end(0, 600, 300))
        self.assertFalse(responsive_audit.scroll_reaches_end(0, 300, 300))


if __name__ == "__main__":
    unittest.main()
