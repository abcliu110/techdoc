import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { categories, components } from "./prototype-suite/catalog.mjs";
import { interactionContracts } from "./prototype-suite/contracts/interactions.mjs";
import { renderersByCategory } from "./prototype-suite/renderers.mjs";
import { buildHandbookHtml, buildIndexHtml } from "./prototype-suite/shell.mjs";

const root = path.dirname(fileURLToPath(import.meta.url));
const rendererKeys = Object.values(renderersByCategory).flatMap((registry) => Object.keys(registry)).sort();
const componentKeys = components.map(({ key }) => key).sort();
const contractKeys = Object.keys(interactionContracts).sort();

if (JSON.stringify(rendererKeys) !== JSON.stringify(componentKeys)) throw new Error("Renderer registry does not match the 309-component catalog");
if (JSON.stringify(contractKeys) !== JSON.stringify(componentKeys)) throw new Error("Interaction contracts do not match the 309-component catalog");
if (new Set(Object.values(renderersByCategory).flatMap((registry) => Object.values(registry))).size !== 309) throw new Error("Renderer functions must be unique references");

for (const category of categories) {
  const modulePath = path.join(root, "prototype-suite", "categories", category.module);
  const source = fs.readFileSync(modulePath, "utf8");
  const registryName = `renderers${category.number}`;
  const buildCategory = {
    ...category,
    components: category.components.map((component) => ({
      ...component,
      contract: interactionContracts[component.key],
    })),
  };
  fs.writeFileSync(path.join(root, category.file), buildHandbookHtml(buildCategory, source, registryName), "utf8");
}

fs.writeFileSync(path.join(root, "prototype-suite", "catalog.browser.json"), JSON.stringify(categories.map((category) => ({
  ...category,
  components: category.components.map((component) => ({
    ...component,
    contract: interactionContracts[component.key],
  })),
})), null, 2), "utf8");

fs.writeFileSync(path.join(root, "复杂UI组件交互原型手册-总索引.html"), buildIndexHtml(categories), "utf8");
console.log(JSON.stringify({ categories: categories.length, components: components.length, renderers: rendererKeys.length, contracts: contractKeys.length, files: categories.length + 1 }));
