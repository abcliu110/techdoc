import { renderers01 } from "./categories/01-layout.mjs";
import { renderers02 } from "./categories/02-table.mjs";
import { renderers03 } from "./categories/03-tree.mjs";
import { renderers04 } from "./categories/04-form.mjs";
import { renderers05 } from "./categories/05-query.mjs";
import { renderers06 } from "./categories/06-selector.mjs";
import { renderers07 } from "./categories/07-editor.mjs";
import { renderers08 } from "./categories/08-lowcode.mjs";
import { renderers09 } from "./categories/09-flow.mjs";
import { renderers15 } from "./categories/15-navigation.mjs";
import { renderers16 } from "./categories/16-permission.mjs";
import { renderers17 } from "./categories/17-collaboration.mjs";
import { renderers18 } from "./categories/18-business.mjs";

export const renderersByCategory = Object.freeze({
  "01": renderers01,
  "02": renderers02,
  "03": renderers03,
  "04": renderers04,
  "05": renderers05,
  "06": renderers06,
  "07": renderers07,
  "08": renderers08,
  "09": renderers09,
  "15": renderers15,
  "16": renderers16,
  "17": renderers17,
  "18": renderers18,
});
