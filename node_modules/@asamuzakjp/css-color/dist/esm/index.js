import { cssCalc } from "./js/css-calc.js";
import { resolveGradient, isGradient } from "./js/css-gradient.js";
import { cssVar } from "./js/css-var.js";
import { splitValue, resolveLengthInPixels, isColor, extractDashedIdent } from "./js/util.js";
import { convert } from "./js/convert.js";
import { resolve } from "./js/resolve.js";
const utils = {
  cssCalc,
  cssVar,
  extractDashedIdent,
  isColor,
  isGradient,
  resolveGradient,
  resolveLengthInPixels,
  splitValue
};
export {
  convert,
  resolve,
  utils
};
//# sourceMappingURL=index.js.map
