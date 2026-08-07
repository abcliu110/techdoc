import json
from pathlib import Path
from urllib.parse import quote

from playwright.sync_api import sync_playwright


ROOT = Path(__file__).resolve().parent.parent
BASE = "http://127.0.0.1:8765"
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
VIEWPORTS = ((360, 800), (390, 844), (759, 900), (761, 900), (1024, 768), (1440, 900))
STATES = ("initial", "exception", "recovery")


def scroll_reaches_end(position, extent, client_extent):
    maximum = extent - client_extent
    return maximum > 0 and position >= maximum - 1


def audit_state(page, component, component_index, width, state_name):
    overflow = page.evaluate("document.documentElement.scrollWidth > document.documentElement.clientWidth")
    small = page.locator("#menu,#prev,#next,#reset,#stage button:not(:disabled)").evaluate_all("nodes => nodes.filter(node => { const r=node.getBoundingClientRect(); const s=getComputedStyle(node); if (r.width === 0 || r.height === 0 || s.display === 'none' || s.visibility === 'hidden') return false; return r.width < 44 || r.height < 44; }).length")

    menu = None
    if component_index == 0 and state_name == "initial" and width <= 760:
        side = page.locator("#side")
        menu_initially_closed = not side.evaluate("node => node.classList.contains('open')")
        page.locator("#menu").click()
        menu_opens = side.evaluate("node => node.classList.contains('open')")
        page.keyboard.press("Escape")
        escape_closes = not side.evaluate("node => node.classList.contains('open')")
        page.locator("#menu").click()
        page.locator("#nav button.active").click()
        selection_closes = not side.evaluate("node => node.classList.contains('open')")
        menu = {"initiallyClosed": menu_initially_closed, "opens": menu_opens, "escapeCloses": escape_closes, "selectionCloses": selection_closes}

    scrolls = page.evaluate("""
        Array.from(document.querySelectorAll('.stage,.prototype-demo,.table-scroll'))
          .filter((node, index, nodes) => nodes.indexOf(node) === index)
          .map((node) => {
            node.scrollLeft = node.scrollWidth;
            node.scrollTop = node.scrollHeight;
            return { className: node.className, left: node.scrollLeft, top: node.scrollTop, width: node.scrollWidth, height: node.scrollHeight, clientWidth: node.clientWidth, clientHeight: node.clientHeight };
          })
    """)
    unreachable = []
    for item in scrolls:
        if item["width"] > item["clientWidth"] and not scroll_reaches_end(item["left"], item["width"], item["clientWidth"]):
            unreachable.append({"className": item["className"], "axis": "x"})
        if item["height"] > item["clientHeight"] and not scroll_reaches_end(item["top"], item["height"], item["clientHeight"]):
            unreachable.append({"className": item["className"], "axis": "y"})

    canvas_present = page.locator("#stage .canvas").count() > 0
    canvas_requires_scroll = canvas_present and page.locator("#stage .canvas").first.evaluate("node => { const stage = node.closest('.stage'); const rect = node.getBoundingClientRect(); return rect.width > stage.clientWidth + 1 || rect.height > stage.clientHeight + 1; }")
    canvas_scrollable = any((item["width"] > item["clientWidth"] or item["height"] > item["clientHeight"]) for item in scrolls if "stage" in item["className"] or "prototype-demo" in item["className"])
    menu_ok = menu is None or all(menu.values())
    if overflow or small or not menu_ok or unreachable or (canvas_requires_scroll and not canvas_scrollable):
        return {"key": component["key"], "viewport": f"{width}x{page.viewport_size['height']}", "state": state_name, "overflow": overflow, "smallTargets": small, "menu": menu, "unreachableScrollEnds": unreachable, "canvasRequiresScroll": canvas_requires_scroll, "canvasScrollable": not canvas_requires_scroll or canvas_scrollable}
    return None


def main():
    catalog = json.loads((ROOT / "prototype-suite" / "catalog.browser.json").read_text(encoding="utf-8"))
    failures = []
    checks = 0
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True, executable_path=CHROME)
        for width, height in VIEWPORTS:
            page = browser.new_page(viewport={"width": width, "height": height})
            for category in catalog:
                for component_index, component in enumerate(category["components"]):
                    url = BASE + "/" + quote(category["file"]) + "#" + quote(component["id"])
                    for state_name in STATES:
                        page.goto(url, wait_until="networkidle")
                        if state_name == "exception":
                            page.locator("[data-readiness-exception]").click()
                        elif state_name == "recovery":
                            page.locator("[data-readiness-exception]").click()
                            page.locator("[data-readiness-recovery]").click()
                        checks += 1
                        failure = audit_state(page, component, component_index, width, state_name)
                        if failure:
                            failures.append(failure)
            page.close()
        browser.close()
    print(json.dumps({"passed": checks - len(failures), "failed": len(failures), "checks": checks, "viewports": len(VIEWPORTS), "states": len(STATES), "failures": failures[:30]}, ensure_ascii=True))
    raise SystemExit(1 if failures else 0)


if __name__ == "__main__":
    main()
