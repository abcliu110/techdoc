import json
from pathlib import Path
from urllib.parse import quote

from playwright.sync_api import sync_playwright


BASE = "http://127.0.0.1:8765"
ROOT = Path(__file__).resolve().parent.parent
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"


def page_url(file_name, component_id):
    return BASE + "/" + quote(file_name) + "#" + quote(component_id)


def state(page):
    return page.locator("#prototypeState").get_attribute("data-state")


def main():
    checks = {}
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True, executable_path=CHROME)
        page = browser.new_page(viewport={"width": 1440, "height": 900})

        table_file = "02-表格类复杂组件交互原型手册.html"
        page.goto(page_url(table_file, "selection-grid"), wait_until="networkidle")
        page.locator("[data-all]").check()
        checks["table-select-all-checks-inputs"] = page.locator("[data-row-check]:checked").count() == 2 and state(page) == "selected:2"

        page.goto(page_url(table_file, "editable-grid"), wait_until="networkidle")
        page.locator("[contenteditable]").focus()
        before = page.locator("#title").inner_text()
        page.keyboard.press("ArrowRight")
        checks["contenteditable-arrows-do-not-navigate"] = page.locator("#title").inner_text() == before

        collaboration_file = "17-消息协作与反馈类复杂组件交互原型手册.html"
        page.goto(page_url(collaboration_file, "instant-chat"), wait_until="networkidle")
        payload = '<img src=x onerror="document.body.dataset.xss=1">'
        page.locator("[data-input]").fill(payload)
        page.locator("[data-action]").click()
        checks["message-input-is-text-not-html"] = page.locator("#stage img").count() == 0 and page.evaluate("document.body.dataset.xss || null") is None and payload in page.locator("[data-messages]").inner_text()

        lowcode_file = "08-页面与低代码设计类复杂组件交互原型手册.html"
        page.goto(page_url(lowcode_file, "schema-editor"), wait_until="networkidle")
        page.locator("textarea").fill("{invalid")
        page.locator('[data-action="schema-validate"]').click()
        checks["schema-invalid-input-is-rejected"] = state(page) == "schema:error" and "上一个有效版本" in page.locator("#stage").inner_text()

        flow_file = "09-流程规则与图形编排类复杂组件交互原型手册.html"
        page.goto(page_url(flow_file, "rule-designer"), wait_until="networkidle")
        page.locator('input[type="number"]').fill("500")
        page.locator("select").select_option("NORMAL")
        page.locator('[data-action="rule-run"]').click()
        checks["rule-result-matches-all-inputs"] = state(page) == "rule:miss"

        page.goto(page_url(flow_file, "decision-table"), wait_until="networkidle")
        page.locator('[data-action="decision-vip"]').click()
        page.locator('[data-action="decision-run"]').click()
        checks["decision-table-reads-cell-state"] = state(page) == "decision:无折扣"

        page.goto(page_url(flow_file, "state-machine"), wait_until="networkidle")
        page.locator('[data-action="state-transition"]').click()
        page.locator("#reset").click()
        page.locator('[data-action="state-transition"]').click()
        checks["state-machine-reset-clears-step"] = state(page) == "state:review"

        page.goto(page_url(lowcode_file, "page-designer"), wait_until="networkidle")
        page.goto(page_url(lowcode_file, "form-designer"), wait_until="networkidle")
        page.go_back(wait_until="networkidle")
        checks["hash-back-forward-rerenders"] = "页面设计器" in page.locator("#title").inner_text() and page.evaluate("location.hash") == "#page-designer"

        layout_file = "复杂布局组件交互原型手册.html"
        page.goto(page_url(layout_file, "drawer-workspace"), wait_until="networkidle")
        page.locator("[data-open]").click()
        page.goto(page_url(layout_file, "grid-layout"), wait_until="networkidle")
        page.wait_for_timeout(100)
        checks["delayed-focus-cancelled-on-unmount"] = "栅格布局" in page.locator("#title").inner_text()

        unnamed = []
        catalog = json.loads((ROOT / "prototype-suite" / "catalog.browser.json").read_text(encoding="utf-8"))
        for category in catalog:
            for component in category["components"]:
                page.goto(page_url(category["file"], component["id"]), wait_until="networkidle")
                details = page.locator("#stage input, #stage select, #stage textarea, #stage button").evaluate_all("""nodes => nodes.filter(node => {
                  if (node.disabled || node.type === 'hidden') return false;
                  const labelled = node.getAttribute('aria-label') || node.getAttribute('aria-labelledby') || node.title || node.labels?.length || node.textContent.trim();
                  return !labelled;
                }).map(node => ({tag: node.tagName, type: node.type, html: node.outerHTML.slice(0, 160)}))""")
                unnamed.extend({"key": component["key"], **detail} for detail in details)
        checks["all-controls-have-accessible-names"] = len(unnamed) == 0
        browser.close()

    failed = [name for name, passed in checks.items() if not passed]
    print(json.dumps({"passed": len(checks) - len(failed), "failed": len(failed), "checks": checks, "unnamed": unnamed[:50]}, ensure_ascii=True))
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
