import argparse
import json
from pathlib import Path
from urllib.parse import quote

from playwright.sync_api import sync_playwright


def state(page):
    return page.locator("#prototypeState").get_attribute("data-state")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8765")
    args = parser.parse_args()

    suite_root = Path(__file__).resolve().parent.parent
    catalog = json.loads((suite_root / "prototype-suite" / "catalog.browser.json").read_text(encoding="utf-8"))
    chrome = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")
    failures = []
    readiness_checks = 0
    primary_checks = 0
    escape_checks = 0

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True, executable_path=str(chrome))
        page = browser.new_page(viewport={"width": 1440, "height": 900})
        for category in catalog:
            file_url = args.url.rstrip("/") + "/" + quote(category["file"])
            for index, component in enumerate(category["components"]):
                page.goto(file_url + "#" + quote(component["id"]), wait_until="networkidle")
                for selector, expected in (("[data-readiness-exception]", "readiness:exception"),):
                    page.locator("#reset").click()
                    control = page.locator(selector)
                    control.focus()
                    control.press("Enter")
                    readiness_checks += 1
                    if state(page) != expected or not control.evaluate("element => element === document.activeElement"):
                        failures.append({"key": component["key"], "selector": selector, "state": state(page)})

                page.locator("#reset").click()
                exception_control = page.locator("[data-readiness-exception]")
                exception_control.focus()
                exception_control.press("Enter")
                recovery_control = page.locator("[data-readiness-recovery]")
                recovery_control.focus()
                recovery_control.press("Enter")
                readiness_checks += 1
                focus_returned = page.locator("#stage").evaluate("stage => stage.contains(document.activeElement)")
                if state(page) != "readiness:recovered" or not focus_returned:
                    failures.append({"key": component["key"], "selector": "[data-readiness-recovery]", "state": state(page)})

                page.locator("#reset").click()
                page.locator("[data-readiness-exception]").focus()
                page.locator("[data-readiness-exception]").press("Enter")
                page.keyboard.press("Escape")
                escape_checks += 1
                if state(page) != "readiness:recovered" or not page.locator("#stage").evaluate("stage => stage.contains(document.activeElement)"):
                    failures.append({"key": component["key"], "reason": "Escape did not recover and return focus"})

                page.locator("#reset").click()
                initial = state(page)
                primary_steps = [item for item in component["contract"]["steps"] if item.get("path") == "primary"]
                for step in primary_steps:
                    selector = step["selector"] if step["selector"].startswith("[data-readiness-") else "#stage " + step["selector"]
                    control = page.locator(selector).first
                    control.focus()
                    if step["action"] == "check" or control.get_attribute("type") in ("checkbox", "radio"):
                        control.press("Space")
                    elif step["action"] == "contextmenu":
                        control.press("Shift+F10")
                    else:
                        control.press("Enter")
                page.wait_for_timeout(30)
                primary_checks += 1
                if state(page) == initial:
                    failures.append({"key": component["key"], "reason": "primary keyboard path unchanged"})
        browser.close()

    print(json.dumps({
        "passed": not failures,
        "readinessChecks": readiness_checks,
        "representativePrimaryChecks": primary_checks,
        "escapeRecoveryChecks": escape_checks,
        "failures": failures[:30],
    }, ensure_ascii=True))
    raise SystemExit(1 if failures else 0)


if __name__ == "__main__":
    main()
