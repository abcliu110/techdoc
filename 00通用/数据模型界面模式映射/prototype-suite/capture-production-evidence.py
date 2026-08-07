import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

from playwright.sync_api import sync_playwright


CASES = (
    ("01", "grid-layout", "initial", 1440, 900),
    ("02", "data-grid", "primary", 1440, 900),
    ("02", "data-grid", "exception", 1440, 900),
    ("16", "permission-matrix", "recovery", 1440, 900),
    ("18", "stock-allocation", "initial", 1440, 900),
    ("18", "stock-allocation", "exception", 390, 844),
)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8765")
    args = parser.parse_args()

    suite_root = Path(__file__).resolve().parent.parent
    output = suite_root / "prototype-suite" / "evidence"
    output.mkdir(exist_ok=True)
    catalog = json.loads((suite_root / "prototype-suite" / "catalog.browser.json").read_text(encoding="utf-8"))
    categories = {category["number"]: category for category in catalog}
    chrome = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")
    screenshots = []

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True, executable_path=str(chrome))
        index_page = browser.new_page(viewport={"width": 1440, "height": 900})
        index_page.goto(args.url.rstrip("/") + "/" + quote("复杂UI组件交互原型手册-总索引.html"), wait_until="networkidle")
        index_path = output / "index-desktop.png"
        index_page.screenshot(path=str(index_path), full_page=True)
        screenshots.append({"case": "index", "path": str(index_path), "viewport": "1440x900", "state": "initial"})
        index_page.close()

        for number, component_id, state_name, width, height in CASES:
            category = categories[number]
            component = next(item for item in category["components"] if item["id"] == component_id)
            page = browser.new_page(viewport={"width": width, "height": height})
            file_url = args.url.rstrip("/") + "/" + quote(category["file"]) + "#" + quote(component_id)
            page.goto(file_url, wait_until="networkidle")
            if state_name == "primary":
                for step in (item for item in component["contract"]["steps"] if item.get("path") == "primary"):
                    selector = step["selector"] if step["selector"].startswith("[data-readiness-") else "#stage " + step["selector"]
                    target = page.locator(selector).first
                    if step["action"] == "check":
                        target.set_checked(step.get("value", True))
                    elif step["action"] == "contextmenu":
                        target.click(button="right")
                    else:
                        target.click()
            elif state_name == "exception":
                page.locator("[data-readiness-exception]").click()
            elif state_name == "recovery":
                page.locator("[data-readiness-exception]").click()
                page.locator("[data-readiness-recovery]").click()
            page.wait_for_timeout(50)
            path = output / f"{number}-{component_id}-{state_name}-{width}x{height}.png"
            page.screenshot(path=str(path), full_page=True)
            screenshots.append({"case": component["key"], "path": str(path), "viewport": f"{width}x{height}", "state": state_name})
            page.close()
        browser.close()

    report = {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "url": args.url,
        "browserPath": "Python Playwright with system Chrome; in-app Browser returned No browser is available",
        "screenshots": screenshots,
    }
    report_path = output / "screenshots.json"
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"screenshots": len(screenshots), "report": str(report_path)}, ensure_ascii=True))


if __name__ == "__main__":
    main()
