"use strict";

const { CSSStyleDeclaration } = require("./CSSStyleDeclaration");
const propertyDefinitions = require("./generated/propertyDefinitions");
const { parsePropertyValue } = require("./parsers");

module.exports = {
  CSSStyleDeclaration,
  parsePropertyValue,
  propertyDefinitions
};
