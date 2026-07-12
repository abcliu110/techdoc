(() => {
  const beforeButtons = Array.from(document.querySelectorAll('[data-role="canvas-field-list"] [data-drag-source="canvas-field"]')).map((el) =>
    el.textContent.trim()
  );
  const source = document.querySelector('[data-drag-source="palette"][data-template-code="number"]');
  const target = document.querySelector('[data-drop-zone-index="1"]');
  if (!source || !target) {
    return JSON.stringify({ ok: false, step: "missing-palette-or-zone", beforeButtons });
  }

  const dt = new DataTransfer();
  source.dispatchEvent(new DragEvent("dragstart", { bubbles: true, cancelable: true, dataTransfer: dt }));
  target.dispatchEvent(new DragEvent("dragover", { bubbles: true, cancelable: true, dataTransfer: dt }));
  target.dispatchEvent(new DragEvent("drop", { bubbles: true, cancelable: true, dataTransfer: dt }));

  const afterButtons = Array.from(document.querySelectorAll('[data-role="canvas-field-list"] [data-drag-source="canvas-field"]')).map((el) =>
    el.textContent.trim()
  );
  const selectedCode =
    Array.from(document.querySelectorAll("input[disabled]"))
      .map((element) => element.value || "")
      .find((value) => value.includes("number_input")) || "";
  return JSON.stringify({
    ok: afterButtons.length === beforeButtons.length + 1 && selectedCode.includes("number_input"),
    beforeCount: beforeButtons.length,
    afterCount: afterButtons.length,
    selectedCode,
    insertedFound: afterButtons.some((text) => text.includes("number_input")),
    hasBetweenDropZone: Boolean(document.querySelector('[data-role="canvas-field-list"] [data-drop-zone-index="1"]')),
    firstAfter: afterButtons.slice(0, 4)
  });
})();
