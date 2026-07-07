import { renderWorkbenchDocument } from "./ui";

const root = document.getElementById("app");

if (!root) {
  throw new Error("应用挂载节点不存在");
}

root.append(renderWorkbenchDocument());
