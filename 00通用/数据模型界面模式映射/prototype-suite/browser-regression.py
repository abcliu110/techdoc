import argparse
import json
from pathlib import Path
from urllib.parse import quote

from playwright.sync_api import sync_playwright


def state_matches(actual, initial, expected):
    if expected == "not:initial":
        return actual != initial
    if expected == "initial":
        return actual == initial
    return actual == expected


def observed_state(page, selector):
    observer = page.locator(selector).first
    state = observer.get_attribute("data-state")
    return state if state is not None else observer.inner_text()


def execute_step(page, step):
    if step["action"] == "auto":
        marked_actions = page.locator("#stage [data-action]")
        action = marked_actions.first if marked_actions.count() else page.locator("#stage button:not(:disabled)").first
    else:
        action = page.locator(step["selector"]).first
    if action.count() == 0:
        return step["selector"]
    if step["action"] == "check":
        action.set_checked(step.get("value", True))
    elif step["action"] == "contextmenu":
        action.click(button="right")
    else:
        action.click()
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8765")
    parser.add_argument("--viewport", default="1440x900")
    parser.add_argument("--categories", default="")
    args = parser.parse_args()

    width, height = [int(value) for value in args.viewport.lower().split("x", 1)]
    suite_root = Path(__file__).resolve().parent.parent
    catalog_path = suite_root / "prototype-suite" / "catalog.browser.json"
    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    selected = {value.strip() for value in args.categories.split(",") if value.strip()}
    categories = [item for item in catalog if not selected or item["number"] in selected]
    chrome = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")
    errors = []
    results = []

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True, executable_path=str(chrome))
        page = browser.new_page(viewport={"width": width, "height": height})
        page.on("pageerror", lambda error: errors.append(str(error)))
        page.on("console", lambda message: errors.append(message.text) if message.type == "error" and "Failed to load resource" not in message.text else None)

        for category in categories:
            file_url = args.url.rstrip("/") + "/" + quote(category["file"])
            for component in category["components"]:
                errors.clear()
                page.goto(file_url + "#" + quote(component["id"]), wait_until="networkidle")
                title = page.locator("#title").inner_text()
                contract = component["contract"]
                initial = observed_state(page, contract["observe"])
                missing_action = None
                path_results = {}
                for path in ("primary", "exception", "recovery"):
                    page.locator("#reset").click()
                    path_steps = [step for step in contract["steps"] if step.get("path", "primary") == path]
                    for step in path_steps:
                        scoped_step = dict(step)
                        if path == "primary" and not step["selector"].startswith(("#", "[data-readiness-")):
                            scoped_step["selector"] = "#stage " + step["selector"]
                        missing_action = execute_step(page, scoped_step)
                        if missing_action:
                            break
                    if missing_action:
                        break
                    page.wait_for_timeout(30)
                    path_results[path] = {
                        "state": observed_state(page, contract["observe"]),
                        "result": page.locator("#readinessResult").inner_text(),
                        "stageLocked": page.locator("#stage").evaluate("stage => stage.getAttribute('aria-disabled') === 'true' && stage.inert && !stage.querySelector('button:not(:disabled),input:not(:disabled),select:not(:disabled),textarea:not(:disabled)')"),
                        "systemDone": page.locator("#systemTimeline [data-system-step].done").count(),
                        "systemError": page.locator("#systemTimeline [data-system-step].error").count(),
                    }
                if missing_action:
                    results.append({"key": component["key"], "status": "fail", "reason": "no action", "selector": missing_action})
                    continue
                changed = path_results["primary"]["state"]
                page.locator("#reset").click()
                reset = observed_state(page, contract["observe"])
                changed_ok = state_matches(changed, initial, contract["changed"])
                reset_ok = state_matches(reset, initial, contract["reset"])
                exception_ok = path_results["exception"]["state"] == "readiness:exception" and contract["business"]["exception"] in path_results["exception"]["result"]
                recovery_ok = path_results["recovery"]["state"] == "readiness:recovered" and contract["readiness"]["recovery"] in path_results["recovery"]["result"]
                primary_result_ok = "主路径完成" in path_results["primary"]["result"] and contract["business"]["effect"] in path_results["primary"]["result"] and changed in path_results["primary"]["result"]
                context_ok = all(page.locator("#taskContext").inner_text().find(value) >= 0 for value in (contract["business"]["role"], contract["business"]["task"], contract["business"]["rule"]))
                stage_locked = path_results["exception"]["stageLocked"]
                page.locator("#reset").click()
                for step in (item for item in contract["steps"] if item.get("path") == "recovery"):
                    execute_step(page, step)
                stage_unlocked = page.locator("#stage").get_attribute("aria-disabled") != "true"
                focus_restored = page.locator("#stage").evaluate("stage => stage.contains(document.activeElement)")
                c_level_visible = True
                if contract["business"]["level"] == "C":
                    c_level_visible = page.locator("#systemReadiness").is_visible() and path_results["primary"]["systemDone"] >= 3 and path_results["exception"]["systemError"] >= 1 and path_results["recovery"]["systemDone"] >= 2 and contract["business"]["compensation"] in page.locator("#systemReadiness").inner_text()
                status = "pass" if component["name"] in title and changed_ok and reset_ok and primary_result_ok and exception_ok and recovery_ok and context_ok and stage_locked and stage_unlocked and focus_restored and c_level_visible and not errors else "fail"
                results.append({
                    "key": component["key"],
                    "status": status,
                    "initial": initial,
                    "changed": changed,
                    "expectedChanged": contract["changed"],
                    "changedMatches": changed_ok,
                    "reset": reset,
                    "expectedReset": contract["reset"],
                    "resetMatches": reset_ok,
                    "primaryResultMatches": primary_result_ok,
                    "exceptionMatches": exception_ok,
                    "recoveryMatches": recovery_ok,
                    "contextMatches": context_ok,
                    "stageLocked": stage_locked,
                    "stageUnlocked": stage_unlocked,
                    "focusRestored": focus_restored,
                    "systemReadinessVisible": c_level_visible,
                    "errors": list(errors),
                })

        browser.close()

    failed = [result for result in results if result["status"] != "pass"]
    expected = sum(len(category["components"]) for category in categories)
    if len(results) != expected:
        failed.append({"key": "suite", "status": "fail", "reason": f"executed {len(results)} of {expected}"})
    print(json.dumps({"passed": len(results) - len(failed), "failed": len(failed), "failures": failed[:30]}, ensure_ascii=True))
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
