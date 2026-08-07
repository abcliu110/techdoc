import { components } from "../catalog.mjs";
import { interactionContractsCore } from "./interactions-core.mjs";
import { middleInteractionContracts } from "./middle-interactions.mjs";
import { enterpriseInteractionContracts } from "./enterprise.mjs";

const baselineContracts = Object.fromEntries(components.map((component) => [
  component.key,
  Object.freeze({
    componentKey: component.key,
    hash: component.id,
    steps: Object.freeze([{ action: "click", selector: "[data-action]" }]),
    observe: "#prototypeState",
    changed: "not:initial",
    reset: "initial",
  }),
]));

export const interactionContracts = Object.freeze({
  ...baselineContracts,
  ...interactionContractsCore,
  ...middleInteractionContracts,
  ...enterpriseInteractionContracts,
});
