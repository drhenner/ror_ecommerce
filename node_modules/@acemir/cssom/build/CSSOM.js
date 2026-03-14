var CSSOM = {
  /**
   * Creates and configures a new CSSOM instance with the specified options.
   * 
   * @param {Object} opts - Configuration options for the CSSOM instance
   * @param {Object} [opts.globalObject] - Optional global object to be assigned to CSSOM objects prototype
   * @returns {Object} A new CSSOM instance with the applied configuration
   * @description
   * This method creates a new instance of CSSOM and optionally
   * configures CSSStyleSheet with a global object reference. When a globalObject is provided
   * and CSSStyleSheet exists on the instance, it creates a new CSSStyleSheet constructor
   * using a factory function and assigns the globalObject to its prototype's __globalObject property.
   */
  setup: function (opts) {
    var instance = Object.create(this);
    if (opts.globalObject) {
      if (instance.CSSStyleSheet) {
        var factoryCSSStyleSheet = createFunctionFactory(instance.CSSStyleSheet);
        var CSSStyleSheet = factoryCSSStyleSheet();
        CSSStyleSheet.prototype.__globalObject = opts.globalObject;

        instance.CSSStyleSheet = CSSStyleSheet;
      }
    }
    return instance;
  }
};

function createFunctionFactory(fn) {
  return function() {
    // Create a new function that delegates to the original
    var newFn = function() {
      return fn.apply(this, arguments);
    };

    // Copy prototype chain
    Object.setPrototypeOf(newFn, Object.getPrototypeOf(fn));

    // Copy own properties
    for (var key in fn) {
      if (Object.prototype.hasOwnProperty.call(fn, key)) {
        newFn[key] = fn[key];
      }
    }

    // Clone the .prototype object for constructor-like behavior
    if (fn.prototype) {
      newFn.prototype = Object.create(fn.prototype);
    }

    return newFn;
  };
}



// Utility functions for CSSOM error handling

/**
 * Gets the appropriate error constructor from the global object context.
 * Tries to find the error constructor from parentStyleSheet.__globalObject,
 * then from __globalObject, then falls back to the native constructor.
 * 
 * @param {Object} context - The CSSOM object (rule, stylesheet, etc.)
 * @param {string} errorType - The error type ('TypeError', 'RangeError', 'DOMException', etc.)
 * @return {Function} The error constructor
 */
function getErrorConstructor(context, errorType) {
	// Try parentStyleSheet.__globalObject first
	if (context.parentStyleSheet && context.parentStyleSheet.__globalObject && context.parentStyleSheet.__globalObject[errorType]) {
		return context.parentStyleSheet.__globalObject[errorType];
	}
	
	// Try __parentStyleSheet (alternative naming)
	if (context.__parentStyleSheet && context.__parentStyleSheet.__globalObject && context.__parentStyleSheet.__globalObject[errorType]) {
		return context.__parentStyleSheet.__globalObject[errorType];
	}
	
	// Try __globalObject on the context itself
	if (context.__globalObject && context.__globalObject[errorType]) {
		return context.__globalObject[errorType];
	}
	
	// Fall back to native constructor
	return (typeof global !== 'undefined' && global[errorType]) || 
	       (typeof window !== 'undefined' && window[errorType]) || 
	       eval(errorType);
}

/**
 * Creates an appropriate error with context-aware constructor.
 * 
 * @param {Object} context - The CSSOM object (rule, stylesheet, etc.)
 * @param {string} errorType - The error type ('TypeError', 'RangeError', 'DOMException', etc.)
 * @param {string} message - The error message
 * @param {string} [name] - Optional name for DOMException
 */
function createError(context, errorType, message, name) {
	var ErrorConstructor = getErrorConstructor(context, errorType);
	return new ErrorConstructor(message, name);
}

/**
 * Creates and throws an appropriate error with context-aware constructor.
 * 
 * @param {Object} context - The CSSOM object (rule, stylesheet, etc.)
 * @param {string} errorType - The error type ('TypeError', 'RangeError', 'DOMException', etc.)
 * @param {string} message - The error message
 * @param {string} [name] - Optional name for DOMException
 */
function throwError(context, errorType, message, name) {
	throw createError(context, errorType, message, name);
}

/**
 * Throws a TypeError for missing required arguments.
 * 
 * @param {Object} context - The CSSOM object
 * @param {string} methodName - The method name (e.g., 'appendRule')
 * @param {string} objectName - The object name (e.g., 'CSSKeyframesRule')
 * @param {number} [required=1] - Number of required arguments
 * @param {number} [provided=0] - Number of provided arguments
 */
function throwMissingArguments(context, methodName, objectName, required, provided) {
	required = required || 1;
	provided = provided || 0;
	var message = "Failed to execute '" + methodName + "' on '" + objectName + "': " + 
	              required + " argument" + (required > 1 ? "s" : "") + " required, but only " + 
	              provided + " present.";
	throwError(context, 'TypeError', message);
}

/**
 * Throws a DOMException for parse errors.
 * 
 * @param {Object} context - The CSSOM object
 * @param {string} methodName - The method name
 * @param {string} objectName - The object name
 * @param {string} rule - The rule that failed to parse
 * @param {string} [name='SyntaxError'] - The DOMException name
 */
function throwParseError(context, methodName, objectName, rule, name) {
	var message = "Failed to execute '" + methodName + "' on '" + objectName + "': " +
	              "Failed to parse the rule '" + rule + "'.";
	throwError(context, 'DOMException', message, name || 'SyntaxError');
}

/**
 * Throws a DOMException for index errors.
 * 
 * @param {Object} context - The CSSOM object
 * @param {string} methodName - The method name
 * @param {string} objectName - The object name
 * @param {number} index - The invalid index
 * @param {number} maxIndex - The maximum valid index
 * @param {string} [name='IndexSizeError'] - The DOMException name
 */
function throwIndexError(context, methodName, objectName, index, maxIndex, name) {
	var message = "Failed to execute '" + methodName + "' on '" + objectName + "': " +
	              "The index provided (" + index + ") is larger than the maximum index (" + maxIndex + ").";
	throwError(context, 'DOMException', message, name || 'IndexSizeError');
}

var errorUtils = {
	createError: createError,
	getErrorConstructor: getErrorConstructor,
	throwError: throwError,
	throwMissingArguments: throwMissingArguments,
	throwParseError: throwParseError,
	throwIndexError: throwIndexError
};

// Shared regex patterns for CSS parsing and validation
// These patterns are compiled once and reused across multiple files for better performance

// Regex patterns for CSS parsing
var atKeyframesRegExp = /@(-(?:\w+-)+)?keyframes/g; // Match @keyframes and vendor-prefixed @keyframes
var beforeRulePortionRegExp = /{(?!.*{)|}(?!.*})|;(?!.*;)|\*\/(?!.*\*\/)/g; // Match the closest allowed character (a opening or closing brace, a semicolon or a comment ending) before the rule
var beforeRuleValidationRegExp = /^[\s{};]*(\*\/\s*)?$/; // Match that the portion before the rule is empty or contains only whitespace, semicolons, opening/closing braces, and optionally a comment ending (*/) followed by whitespace
var forwardRuleValidationRegExp = /(?:\s|\/\*|\{|\()/; // Match that the rule is followed by any whitespace, a opening comment, a condition opening parenthesis or a opening brace
var forwardImportRuleValidationRegExp = /(?:\s|\/\*|'|")/; // Match that the rule is followed by any whitespace, an opening comment, a single quote or double quote
var forwardRuleClosingBraceRegExp = /{[^{}]*}|}/; // Finds the next closing brace of a rule block
var forwardRuleSemicolonAndOpeningBraceRegExp = /^.*?({|;)/; // Finds the next semicolon or opening brace after the at-rule

// Regex patterns for CSS selector validation and parsing
var cssCustomIdentifierRegExp = /^(-?[_a-zA-Z]+(\.[_a-zA-Z]+)*[_a-zA-Z0-9-]*)$/; // Validates a css custom identifier
var startsWithCombinatorRegExp = /^\s*[>+~]/; // Checks if a selector starts with a CSS combinator (>, +, ~)

/**
 * Parse `@page` selectorText for page name and pseudo-pages
 * Valid formats:
 * - (empty - no name, no pseudo-page)
 * - `:left`, `:right`, `:first`, `:blank` (pseudo-page only)
 * - `named` (named page only)
 * - `named:first` (named page with single pseudo-page)
 * - `named:first:left` (named page with multiple pseudo-pages)
 */
var atPageRuleSelectorRegExp = /^([^\s:]+)?((?::\w+)*)$/; // Validates @page rule selectors

// Regex patterns for CSSImportRule parsing
var layerRegExp = /layer\(([^)]*)\)/; // Matches layer() function in @import
var layerRuleNameRegExp = /^(-?[_a-zA-Z]+(\.[_a-zA-Z]+)*[_a-zA-Z0-9-]*)$/; // Validates layer name (same as custom identifier)
var doubleOrMoreSpacesRegExp = /\s{2,}/g; // Matches two or more consecutive whitespace characters


// Regex patterns for CSS escape sequences and identifiers
var startsWithHexEscapeRegExp = /^\\[0-9a-fA-F]/; // Checks if escape sequence starts with hex escape
var identStartCharRegExp = /[a-zA-Z_\u00A0-\uFFFF]/; // Valid identifier start character
var identCharRegExp = /^[a-zA-Z0-9_\-\u00A0-\uFFFF\\]/; // Valid identifier character
var specialCharsNeedEscapeRegExp = /[!"#$%&'()*+,./:;<=>?@\[\\\]^`{|}~\s]/; // Characters that need escaping
var combinatorOrSeparatorRegExp = /[\s>+~,()]/; // Selector boundaries and combinators
var afterHexEscapeSeparatorRegExp = /[\s>+~,(){}\[\]]/; // Characters that separate after hex escape
var trailingSpaceSeparatorRegExp = /[\s>+~,(){}]/; // Characters that allow trailing space
var endsWithHexEscapeRegExp = /\\[0-9a-fA-F]{1,6}\s+$/; // Matches selector ending with hex escape + space(s)

/**
 * Regular expression to detect invalid characters in the value portion of a CSS style declaration.
 *
 * This regex matches a colon (:) that is not inside parentheses and not inside single or double quotes.
 * It is used to ensure that the value part of a CSS property does not contain unexpected colons,
 * which would indicate a malformed declaration (e.g., "color: foo:bar;" is invalid).
 *
 * The negative lookahead `(?![^(]*\))` ensures that the colon is not followed by a closing
 * parenthesis without encountering an opening parenthesis, effectively ignoring colons inside
 * function-like values (e.g., `url(data:image/png;base64,...)`).
 *
 * The lookahead `(?=(?:[^'"]|'[^']*'|"[^"]*")*$)` ensures that the colon is not inside single or double quotes,
 * allowing colons within quoted strings (e.g., `content: ":";` or `background: url("foo:bar.png");`).
 *
 * Example:
 * - `color: red;`         // valid, does not match
 * - `background: url(data:image/png;base64,...);` // valid, does not match
 * - `content: ':';`       // valid, does not match
 * - `color: foo:bar;`     // invalid, matches
 */
var basicStylePropertyValueValidationRegExp = /:(?![^(]*\))(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/;

// Attribute selector pattern: matches attribute-name operator value
// Operators: =, ~=, |=, ^=, $=, *=
// Rewritten to avoid ReDoS by using greedy match and trimming in JavaScript
var attributeSelectorContentRegExp = /^([^\s=~|^$*]+)\s*(~=|\|=|\^=|\$=|\*=|=)\s*(.+)$/;

// Selector validation patterns
var pseudoElementRegExp = /::[a-zA-Z][\w-]*|:(before|after|first-line|first-letter)(?![a-zA-Z0-9_-])/; // Matches pseudo-elements
var invalidCombinatorLtGtRegExp = /<>/; // Invalid <> combinator
var invalidCombinatorDoubleGtRegExp = />>/; // Invalid >> combinator
var consecutiveCombinatorsRegExp = /[>+~]\s*[>+~]/; // Invalid consecutive combinators
var invalidSlottedRegExp = /(?:^|[\s>+~,\[])slotted\s*\(/i; // Invalid slotted() without ::
var invalidPartRegExp = /(?:^|[\s>+~,\[])part\s*\(/i; // Invalid part() without ::
var invalidCueRegExp = /(?:^|[\s>+~,\[])cue\s*\(/i; // Invalid cue() without ::
var invalidCueRegionRegExp = /(?:^|[\s>+~,\[])cue-region\s*\(/i; // Invalid cue-region() without ::
var invalidNestingPattern = /&(?![.\#\[:>\+~\s])[a-zA-Z]/; // Invalid & followed by type selector
var emptyPseudoClassRegExp = /:(?:is|not|where|has)\(\s*\)/; // Empty pseudo-class like :is()
var whitespaceNormalizationRegExp = /(['"])(?:\\.|[^\\])*?\1|(\r\n|\r|\n)/g; // Normalize newlines outside quotes
var newlineRemovalRegExp = /\n/g; // Remove all newlines
var whitespaceAndDotRegExp = /[\s.]/; // Matches whitespace or dot
var declarationOrOpenBraceRegExp = /[{;}]/; // Matches declaration separator or open brace
var ampersandRegExp = /&/; // Matches nesting selector
var hexEscapeSequenceRegExp = /^([0-9a-fA-F]{1,6})[ \t\r\n\f]?/; // Matches hex escape sequence (1-6 hex digits optionally followed by whitespace)
var attributeCaseFlagRegExp = /^(.+?)\s+([is])$/i; // Matches case-sensitivity flag at end of attribute value
var prependedAmpersandRegExp = /^&\s+[:\\.]/; // Matches prepended ampersand pattern (& followed by space and : or .)
var openBraceGlobalRegExp = /{/g; // Matches opening braces (global)
var closeBraceGlobalRegExp = /}/g; // Matches closing braces (global)
var scopePreludeSplitRegExp = /\s*\)\s*to\s+\(/; // Splits scope prelude by ") to ("
var leadingWhitespaceRegExp = /^\s+/; // Matches leading whitespace (used to implement a ES5-compliant alternative to trimStart())
var doubleQuoteRegExp = /"/g; // Match all double quotes (for escaping in attribute values)
var backslashRegExp = /\\/g; // Match all backslashes (for escaping in attribute values)

var regexPatterns = {
	// Parsing patterns
	atKeyframesRegExp: atKeyframesRegExp,
	beforeRulePortionRegExp: beforeRulePortionRegExp,
	beforeRuleValidationRegExp: beforeRuleValidationRegExp,
	forwardRuleValidationRegExp: forwardRuleValidationRegExp,
	forwardImportRuleValidationRegExp: forwardImportRuleValidationRegExp,
	forwardRuleClosingBraceRegExp: forwardRuleClosingBraceRegExp,
	forwardRuleSemicolonAndOpeningBraceRegExp: forwardRuleSemicolonAndOpeningBraceRegExp,
	
	// Selector validation patterns
	cssCustomIdentifierRegExp: cssCustomIdentifierRegExp,
	startsWithCombinatorRegExp: startsWithCombinatorRegExp,
	atPageRuleSelectorRegExp: atPageRuleSelectorRegExp,
	
	// Parsing patterns used in CSSImportRule
	layerRegExp: layerRegExp,
	layerRuleNameRegExp: layerRuleNameRegExp,
	doubleOrMoreSpacesRegExp: doubleOrMoreSpacesRegExp,
	
	// Escape sequence and identifier patterns
	startsWithHexEscapeRegExp: startsWithHexEscapeRegExp,
	identStartCharRegExp: identStartCharRegExp,
	identCharRegExp: identCharRegExp,
	specialCharsNeedEscapeRegExp: specialCharsNeedEscapeRegExp,
	combinatorOrSeparatorRegExp: combinatorOrSeparatorRegExp,
	afterHexEscapeSeparatorRegExp: afterHexEscapeSeparatorRegExp,
	trailingSpaceSeparatorRegExp: trailingSpaceSeparatorRegExp,
	endsWithHexEscapeRegExp: endsWithHexEscapeRegExp,

	// Basic style property value validation
	basicStylePropertyValueValidationRegExp: basicStylePropertyValueValidationRegExp,

	// Attribute selector patterns
	attributeSelectorContentRegExp: attributeSelectorContentRegExp,

	// Selector validation patterns
	pseudoElementRegExp: pseudoElementRegExp,
	invalidCombinatorLtGtRegExp: invalidCombinatorLtGtRegExp,
	invalidCombinatorDoubleGtRegExp: invalidCombinatorDoubleGtRegExp,
	consecutiveCombinatorsRegExp: consecutiveCombinatorsRegExp,
	invalidSlottedRegExp: invalidSlottedRegExp,
	invalidPartRegExp: invalidPartRegExp,
	invalidCueRegExp: invalidCueRegExp,
	invalidCueRegionRegExp: invalidCueRegionRegExp,
	invalidNestingPattern: invalidNestingPattern,
	emptyPseudoClassRegExp: emptyPseudoClassRegExp,
	whitespaceNormalizationRegExp: whitespaceNormalizationRegExp,
	newlineRemovalRegExp: newlineRemovalRegExp,
	whitespaceAndDotRegExp: whitespaceAndDotRegExp,
	declarationOrOpenBraceRegExp: declarationOrOpenBraceRegExp,
	ampersandRegExp: ampersandRegExp,
	hexEscapeSequenceRegExp: hexEscapeSequenceRegExp,
	attributeCaseFlagRegExp: attributeCaseFlagRegExp,
	prependedAmpersandRegExp: prependedAmpersandRegExp,
	openBraceGlobalRegExp: openBraceGlobalRegExp,
	closeBraceGlobalRegExp: closeBraceGlobalRegExp,
	scopePreludeSplitRegExp: scopePreludeSplitRegExp,
	leadingWhitespaceRegExp: leadingWhitespaceRegExp,
	doubleQuoteRegExp: doubleQuoteRegExp,
	backslashRegExp: backslashRegExp
};




/**
 * @constructor
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleDeclaration
 */
CSSOM.CSSStyleDeclaration = function CSSStyleDeclaration(){
	this.length = 0;
	this.parentRule = null;

	// NON-STANDARD
	this._importants = {};
};


CSSOM.CSSStyleDeclaration.prototype = {

	constructor: CSSOM.CSSStyleDeclaration,

	/**
	 *
	 * @param {string} name
	 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleDeclaration-getPropertyValue
	 * @return {string} the value of the property if it has been explicitly set for this declaration block.
	 * Returns the empty string if the property has not been set.
	 */
	getPropertyValue: function(name) {
		return this[name] || "";
	},

	/**
	 *
	 * @param {string} name
	 * @param {string} value
	 * @param {string} [priority=null] "important" or null
	 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleDeclaration-setProperty
	 */
	setProperty: function(name, value, priority, parseErrorHandler) 
	{
		// NOTE: Check viability to add a validation for css values or use a dependency like csstree-validator
		var basicStylePropertyValueValidationRegExp = regexPatterns.basicStylePropertyValueValidationRegExp
		if (basicStylePropertyValueValidationRegExp.test(value)) {
			parseErrorHandler && parseErrorHandler('Invalid CSSStyleDeclaration property (name = "' + name + '", value = "' + value + '")');
		} else if (this[name]) {
			// Property already exist. Overwrite it.
			var index = Array.prototype.indexOf.call(this, name);
			if (index < 0) {
				this[this.length] = name;
				this.length++;
			}
	
			// If the priority value of the incoming property is "important",
			// or the value of the existing property is not "important", 
			// then remove the existing property and rewrite it.
			if (priority || !this._importants[name]) {
				this.removeProperty(name);
				this[this.length] = name;
				this.length++;
				this[name] = value + '';
				this._importants[name] = priority;
			}
		} else {
			// New property.
			this[this.length] = name;
			this.length++;
			this[name] = value + '';
			this._importants[name] = priority;
		}
	},

	/**
	 *
	 * @param {string} name
	 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleDeclaration-removeProperty
	 * @return {string} the value of the property if it has been explicitly set for this declaration block.
	 * Returns the empty string if the property has not been set or the property name does not correspond to a known CSS property.
	 */
	removeProperty: function(name) {
		if (!(name in this)) {
			return "";
		}
		var index = Array.prototype.indexOf.call(this, name);
		if (index < 0) {
			return "";
		}
		var prevValue = this[name];
		this[name] = "";

		// That's what WebKit and Opera do
		Array.prototype.splice.call(this, index, 1);

		// That's what Firefox does
		//this[index] = ""

		return prevValue;
	},

	getPropertyCSSValue: function() {
		//FIXME
	},

	/**
	 *
	 * @param {String} name
	 */
	getPropertyPriority: function(name) {
		return this._importants[name] || "";
	},


	/**
	 *   element.style.overflow = "auto"
	 *   element.style.getPropertyShorthand("overflow-x")
	 *   -> "overflow"
	 */
	getPropertyShorthand: function() {
		//FIXME
	},

	isPropertyImplicit: function() {
		//FIXME
	},

	// Doesn't work in IE < 9
	get cssText(){
		var properties = [];
		for (var i=0, length=this.length; i < length; ++i) {
			var name = this[i];
			var value = this.getPropertyValue(name);
			var priority = this.getPropertyPriority(name);
			if (priority) {
				priority = " !" + priority;
			}
			properties[i] = name + ": " + value + priority + ";";
		}
		return properties.join(" ");
	},

	set cssText(text){
		var i, name;
		for (i = this.length; i--;) {
			name = this[i];
			this[name] = "";
		}
		Array.prototype.splice.call(this, 0, this.length);
		this._importants = {};

		var dummyRule = CSSOM.parse('#bogus{' + text + '}').cssRules[0].style;
		var length = dummyRule.length;
		for (i = 0; i < length; ++i) {
			name = dummyRule[i];
			this.setProperty(dummyRule[i], dummyRule.getPropertyValue(name), dummyRule.getPropertyPriority(name));
		}
	}
};



try {
	CSSOM.CSSStyleDeclaration = require("cssstyle").CSSStyleDeclaration;
} catch (e) {
	// ignore
}

/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#the-cssrule-interface
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSRule
 */
CSSOM.CSSRule = function CSSRule() {
  this.__parentRule = null;
  this.__parentStyleSheet = null;
};

CSSOM.CSSRule.UNKNOWN_RULE = 0; // obsolete
CSSOM.CSSRule.STYLE_RULE = 1;
CSSOM.CSSRule.CHARSET_RULE = 2; // obsolete
CSSOM.CSSRule.IMPORT_RULE = 3;
CSSOM.CSSRule.MEDIA_RULE = 4;
CSSOM.CSSRule.FONT_FACE_RULE = 5;
CSSOM.CSSRule.PAGE_RULE = 6;
CSSOM.CSSRule.KEYFRAMES_RULE = 7;
CSSOM.CSSRule.KEYFRAME_RULE = 8;
CSSOM.CSSRule.MARGIN_RULE = 9;
CSSOM.CSSRule.NAMESPACE_RULE = 10;
CSSOM.CSSRule.COUNTER_STYLE_RULE = 11;
CSSOM.CSSRule.SUPPORTS_RULE = 12;
CSSOM.CSSRule.DOCUMENT_RULE = 13;
CSSOM.CSSRule.FONT_FEATURE_VALUES_RULE = 14;
CSSOM.CSSRule.VIEWPORT_RULE = 15;
CSSOM.CSSRule.REGION_STYLE_RULE = 16;
CSSOM.CSSRule.CONTAINER_RULE = 17;
CSSOM.CSSRule.LAYER_BLOCK_RULE = 18;
CSSOM.CSSRule.STARTING_STYLE_RULE = 1002;

Object.defineProperties(CSSOM.CSSRule.prototype, {

  constructor: { value: CSSOM.CSSRule },

  cssRule: {
    value: "",
    configurable: true,
    enumerable: true
  },

  cssText: {
    get: function() {
      // Default getter: subclasses should override this
      return "";
    },
    set: function(cssText) {
      return cssText;
    }
  },

  parentRule: {
    get: function() {
      return this.__parentRule
    }
  },

  parentStyleSheet: {
    get: function() {
      return this.__parentStyleSheet
    }
  },
  
  UNKNOWN_RULE: { value: 0, enumerable: true }, // obsolet
  STYLE_RULE: { value: 1, enumerable: true },
  CHARSET_RULE: { value: 2, enumerable: true }, // obsolet
  IMPORT_RULE: { value: 3, enumerable: true },
  MEDIA_RULE: { value: 4, enumerable: true },
  FONT_FACE_RULE: { value: 5, enumerable: true },
  PAGE_RULE: { value: 6, enumerable: true },
  KEYFRAMES_RULE: { value: 7, enumerable: true },
  KEYFRAME_RULE: { value: 8, enumerable: true },
  MARGIN_RULE: { value: 9, enumerable: true },
  NAMESPACE_RULE: { value: 10, enumerable: true },
  COUNTER_STYLE_RULE: { value: 11, enumerable: true },
  SUPPORTS_RULE: { value: 12, enumerable: true },
  DOCUMENT_RULE: { value: 13, enumerable: true },
  FONT_FEATURE_VALUES_RULE: { value: 14, enumerable: true },
  VIEWPORT_RULE: { value: 15, enumerable: true },
  REGION_STYLE_RULE: { value: 16, enumerable: true },
  CONTAINER_RULE: { value: 17, enumerable: true },
  LAYER_BLOCK_RULE: { value: 18, enumerable: true },
  STARTING_STYLE_RULE: { value: 1002, enumerable: true },
});





/**
 * @constructor
 * @see https://drafts.csswg.org/cssom/#the-cssrulelist-interface
 */
CSSOM.CSSRuleList = function CSSRuleList(){
  var arr = new Array();
  Object.setPrototypeOf(arr, CSSOM.CSSRuleList.prototype);
  return arr;
};

CSSOM.CSSRuleList.prototype = Object.create(Array.prototype);
CSSOM.CSSRuleList.prototype.constructor = CSSOM.CSSRuleList;

CSSOM.CSSRuleList.prototype.item = function(index) {
    return this[index] || null;
};






/**
 * @constructor
 * @see https://drafts.csswg.org/css-nesting-1/
 */
CSSOM.CSSNestedDeclarations = function CSSNestedDeclarations() {
  CSSOM.CSSRule.call(this);
  this.__style = new CSSOM.CSSStyleDeclaration();
  this.__style.parentRule = this;
};

CSSOM.CSSNestedDeclarations.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSNestedDeclarations.prototype.constructor = CSSOM.CSSNestedDeclarations;

Object.setPrototypeOf(CSSOM.CSSNestedDeclarations, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSNestedDeclarations.prototype, "type", {
  value: 0,
  writable: false
});

Object.defineProperty(CSSOM.CSSNestedDeclarations.prototype, "style", {
	get: function() {
		return this.__style;	
	},
	set: function(value) {
		if (typeof value === "string") {
			this.__style.cssText = value;
		} else {
			this.__style = value;
		}
	}
});

Object.defineProperty(CSSOM.CSSNestedDeclarations.prototype, "cssText", {
  get: function () {
    return this.style.cssText;
  }
});




/**
 * @constructor
 * @see https://drafts.csswg.org/cssom/#the-cssgroupingrule-interface
 */
CSSOM.CSSGroupingRule = function CSSGroupingRule() {
	CSSOM.CSSRule.call(this);
	this.__cssRules = new CSSOM.CSSRuleList();
};

CSSOM.CSSGroupingRule.prototype  = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSGroupingRule.prototype.constructor = CSSOM.CSSGroupingRule;

Object.setPrototypeOf(CSSOM.CSSGroupingRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSGroupingRule.prototype, "cssRules", {
	get: function() {
		return this.__cssRules;
	}
});

/**
 * Used to insert a new CSS rule to a list of CSS rules.
 *
 * @example
 *   cssGroupingRule.cssText
 *   -> "body{margin:0;}"
 *   cssGroupingRule.insertRule("img{border:none;}", 1)
 *   -> 1
 *   cssGroupingRule.cssText
 *   -> "body{margin:0;}img{border:none;}"
 *
 * @param {string} rule
 * @param {number} [index]
 * @see https://www.w3.org/TR/cssom-1/#dom-cssgroupingrule-insertrule
 * @return {number} The index within the grouping rule's collection of the newly inserted rule.
 */
 CSSOM.CSSGroupingRule.prototype.insertRule = function insertRule(rule, index) {
	if (rule === undefined && index === undefined) {
		errorUtils.throwMissingArguments(this, 'insertRule', this.constructor.name);
	}
	if (index === void 0) {
		index = 0;
	}
	index = Number(index);
	if (index < 0) {
		index = 4294967296 + index;
	}
	if (index > this.cssRules.length) {
		errorUtils.throwIndexError(this, 'insertRule', this.constructor.name, index, this.cssRules.length);
	}
	var ruleToParse = processedRuleToParse = String(rule);
	ruleToParse = ruleToParse.trim().replace(/^\/\*[\s\S]*?\*\/\s*/, "");
	var isNestedSelector = this.constructor.name === "CSSStyleRule";
	if (isNestedSelector === false) {
		var currentRule = this;
		while (currentRule.parentRule) {
			currentRule = currentRule.parentRule;
			if (currentRule.constructor.name === "CSSStyleRule") {
				isNestedSelector = true;
				break;
			}
		}
	}
	if (isNestedSelector) {
		processedRuleToParse = 's { n { } ' + ruleToParse + '}';
	}
	var isScopeRule = this.constructor.name === "CSSScopeRule";
	if (isScopeRule) {
		if (isNestedSelector) {
			processedRuleToParse = 's { ' + '@scope {' + ruleToParse + '}}';
		} else {
			processedRuleToParse = '@scope {' + ruleToParse + '}';
		}
	}
	var parsedRules = new CSSOM.CSSRuleList();
	CSSOM.parse(processedRuleToParse, {
		styleSheet: this.parentStyleSheet,
		cssRules: parsedRules
	});
	if (isScopeRule) {
		if (isNestedSelector) {
			parsedRules = parsedRules[0].cssRules[0].cssRules;
		} else {
			parsedRules = parsedRules[0].cssRules
		}
	}
	if (isNestedSelector) {
		parsedRules = parsedRules[0].cssRules.slice(1);
	}
	if (parsedRules.length !== 1) {
		if (isNestedSelector && parsedRules.length === 0 && ruleToParse.indexOf('@font-face') === 0) {
			errorUtils.throwError(this, 'DOMException', 
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': " +
				"Only conditional nested group rules, style rules, @scope rules, @apply rules, and nested declaration rules may be nested.",
				'HierarchyRequestError');
		} else {
			errorUtils.throwParseError(this, 'insertRule', this.constructor.name, ruleToParse, 'SyntaxError');
		}
	}
	var cssRule = parsedRules[0];

	if (cssRule.constructor.name === 'CSSNestedDeclarations' && cssRule.style.length === 0) {
		errorUtils.throwParseError(this, 'insertRule', this.constructor.name, ruleToParse, 'SyntaxError');	
	}
	
	// Check for rules that cannot be inserted inside a CSSGroupingRule
	if (cssRule.constructor.name === 'CSSImportRule' || cssRule.constructor.name === 'CSSNamespaceRule') {
		var ruleKeyword = cssRule.constructor.name === 'CSSImportRule' ? '@import' : '@namespace';
		errorUtils.throwError(this, 'DOMException', 
			"Failed to execute 'insertRule' on '" + this.constructor.name + "': " +
			"'" + ruleKeyword + "' rules cannot be inserted inside a group rule.",
			'HierarchyRequestError');
	}
	
	// Check for CSSLayerStatementRule (@layer statement rules)
	if (cssRule.constructor.name === 'CSSLayerStatementRule') {
		errorUtils.throwParseError(this, 'insertRule', this.constructor.name, ruleToParse, 'SyntaxError');
	}
	
	cssRule.__parentRule = this;
	this.cssRules.splice(index, 0, cssRule);
	return index;
};

/**
 * Used to delete a rule from the grouping rule.
 *
 *   cssGroupingRule.cssText
 *   -> "img{border:none;}body{margin:0;}"
 *   cssGroupingRule.deleteRule(0)
 *   cssGroupingRule.cssText
 *   -> "body{margin:0;}"
 *
 * @param {number} index within the grouping rule's rule list of the rule to remove.
 * @see https://www.w3.org/TR/cssom-1/#dom-cssgroupingrule-deleterule
 */
 CSSOM.CSSGroupingRule.prototype.deleteRule = function deleteRule(index) {
	if (index === undefined) {
		errorUtils.throwMissingArguments(this, 'deleteRule', this.constructor.name);
	}
	index = Number(index);
	if (index < 0) {
		index = 4294967296 + index;
	}
	if (index >= this.cssRules.length) {
		errorUtils.throwIndexError(this, 'deleteRule', this.constructor.name, index, this.cssRules.length);
	}
	this.cssRules[index].__parentRule = null;
	this.cssRules[index].__parentStyleSheet = null;
	this.cssRules.splice(index, 1);
};





/**
 * @constructor
 * @see https://drafts.csswg.org/css-counter-styles/#the-csscounterstylerule-interface
 */
CSSOM.CSSCounterStyleRule = function CSSCounterStyleRule() {
	CSSOM.CSSRule.call(this);
    this.name = "";
	this.__props = "";
};

CSSOM.CSSCounterStyleRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSCounterStyleRule.prototype.constructor = CSSOM.CSSCounterStyleRule;

Object.setPrototypeOf(CSSOM.CSSCounterStyleRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSCounterStyleRule.prototype, "type", {
	value: 11,
	writable: false
});

Object.defineProperty(CSSOM.CSSCounterStyleRule.prototype, "cssText", {
	get: function() {
		// FIXME : Implement real cssText generation based on properties
		return "@counter-style " + this.name + " { " + this.__props + " }";
	}
});

/**
 * NON-STANDARD
 * Rule text parser.
 * @param {string} cssText
 */
Object.defineProperty(CSSOM.CSSCounterStyleRule.prototype, "parse", {
	value: function(cssText) {
		// Extract the name from "@counter-style <name> { ... }"
		var match = cssText.match(/@counter-style\s+([^\s{]+)\s*\{([^]*)\}/);
		if (match) {
			this.name = match[1];
			// Get the text inside the brackets and clean it up
			var propsText = match[2];
			this.__props = propsText.trim().replace(/\n/g, " ").replace(/(['"])(?:\\.|[^\\])*?\1|(\s{2,})/g, function (match, quote) {
				return quote ? match : ' ';
			});
		}
	}
});





/**
 * @constructor
 * @see https://drafts.css-houdini.org/css-properties-values-api/#the-css-property-rule-interface
 */
CSSOM.CSSPropertyRule = function CSSPropertyRule() {
	CSSOM.CSSRule.call(this);
	this.__name = "";
	this.__syntax = "";
	this.__inherits = false;
	this.__initialValue = null;
};

CSSOM.CSSPropertyRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSPropertyRule.prototype.constructor = CSSOM.CSSPropertyRule;

Object.setPrototypeOf(CSSOM.CSSPropertyRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "type", {
	value: 0,
	writable: false
});

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "cssText", {
	get: function() {
		var text = "@property " + this.name + " {";
		if (this.syntax !== "") {
			text += " syntax: \"" + this.syntax.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + "\";";
		}
		text += " inherits: " + (this.inherits ? "true" : "false") + ";";
		if (this.initialValue !== null) {
			text += " initial-value: " + this.initialValue + ";";
		}
		text += " }";
		return text;
	}
});

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "name", {
	get: function() {
		return this.__name;
	}
});

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "syntax", {
	get: function() {
		return this.__syntax;
	}
});

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "inherits", {
	get: function() {
		return this.__inherits;
	}
});

Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "initialValue", {
	get: function() {
		return this.__initialValue;
	}
});

/**
 * NON-STANDARD
 * Rule text parser.
 * @param {string} cssText
 * @returns {boolean} True if the rule is valid and was parsed successfully
 */
Object.defineProperty(CSSOM.CSSPropertyRule.prototype, "parse", {
	value: function(cssText) {
		// Extract the name from "@property <name> { ... }"
		var match = cssText.match(/@property\s+(--[^\s{]+)\s*\{([^]*)\}/);
		if (!match) {
			return false;
		}
		
		this.__name = match[1];
		var bodyText = match[2];
		
		// Parse syntax descriptor (REQUIRED)
		var syntaxMatch = bodyText.match(/syntax\s*:\s*(['"])([^]*?)\1\s*;/);
		if (!syntaxMatch) {
			return false; // syntax is required
		}
		this.__syntax = syntaxMatch[2];
		
		// Syntax cannot be empty
		if (this.__syntax === "") {
			return false;
		}
		
		// Parse inherits descriptor (REQUIRED)
		var inheritsMatch = bodyText.match(/inherits\s*:\s*(true|false)\s*;/);
		if (!inheritsMatch) {
			return false; // inherits is required
		}
		this.__inherits = inheritsMatch[1] === "true";
		
		// Parse initial-value descriptor (OPTIONAL, but required if syntax is not "*")
		var initialValueMatch = bodyText.match(/initial-value\s*:\s*([^;]+);/);
		if (initialValueMatch) {
			this.__initialValue = initialValueMatch[1].trim();
		} else {
			// If syntax is not "*", initial-value is required
			if (this.__syntax !== "*") {
				return false;
			}
		}
		
		return true; // Successfully parsed
	}
});





/**
 * @constructor
 * @see https://www.w3.org/TR/css-conditional-3/#the-cssconditionrule-interface
 */
CSSOM.CSSConditionRule = function CSSConditionRule() {
  CSSOM.CSSGroupingRule.call(this);
  this.__conditionText = '';
};

CSSOM.CSSConditionRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSConditionRule.prototype.constructor = CSSOM.CSSConditionRule;

Object.setPrototypeOf(CSSOM.CSSConditionRule, CSSOM.CSSGroupingRule);

Object.defineProperty(CSSOM.CSSConditionRule.prototype, "conditionText", {
  get: function () {
    return this.__conditionText;
  }
});





/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#cssstylerule
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleRule
 */
CSSOM.CSSStyleRule = function CSSStyleRule() {
	CSSOM.CSSGroupingRule.call(this);
	this.__selectorText = "";
	this.__style = new CSSOM.CSSStyleDeclaration();
	this.__style.parentRule = this;
};

CSSOM.CSSStyleRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSStyleRule.prototype.constructor = CSSOM.CSSStyleRule;

Object.setPrototypeOf(CSSOM.CSSStyleRule, CSSOM.CSSGroupingRule);

Object.defineProperty(CSSOM.CSSStyleRule.prototype, "type", {
	value: 1,
	writable: false
});

Object.defineProperty(CSSOM.CSSStyleRule.prototype, "selectorText", {
	get: function() {
		return this.__selectorText;	
	},
	set: function(value) {
		if (typeof value === "string") {
			// Don't trim if the value ends with a hex escape sequence followed by space
			// (e.g., ".\31 " where the space is part of the escape terminator)
			var endsWithHexEscapeRegExp = regexPatterns.endsWithHexEscapeRegExp;
			var endsWithEscape = endsWithHexEscapeRegExp.test(value);
			var trimmedValue = endsWithEscape ? value.replace(/\s+$/, ' ').trimStart() : value.trim();

			if (trimmedValue === '') {
				return;
			}

			// TODO: Setting invalid selectorText should be ignored
			// There are some validations already on lib/parse.js
			// but the same validations should be applied here.
			// Check if we can move these validation logic to a shared function.

			this.__selectorText = trimmedValue;
		}
	},
	configurable: true
});

Object.defineProperty(CSSOM.CSSStyleRule.prototype, "style", {
	get: function() {
		return this.__style;	
	},
	set: function(value) {
		if (typeof value === "string") {
			this.__style.cssText = value;
		} else {
			this.__style = value;
		}
	},
	configurable: true
});

Object.defineProperty(CSSOM.CSSStyleRule.prototype, "cssText", {
	get: function() {
		var text;
		if (this.selectorText) {
			var values = "";
			if (this.cssRules.length) {
				var valuesArr = [" {"];
				this.style.cssText && valuesArr.push(this.style.cssText);
				valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
					if (rule.cssText !== "") {
						acc.push(rule.cssText);
					}
					return acc;
				}, []).join("\n  "));
				values = valuesArr.join("\n  ") + "\n}";
			} else {
				values = " {" + (this.style.cssText ? " " + this.style.cssText : "") + " }";
			}
			text = this.selectorText + values;
		} else {
			text = "";
		}
		return text;
	}
});





/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#the-medialist-interface
 */
CSSOM.MediaList = function MediaList(){
	this.length = 0;
};

CSSOM.MediaList.prototype = {

	constructor: CSSOM.MediaList,

	/**
	 * @return {string}
	 */
	get mediaText() {
		return Array.prototype.join.call(this, ", ");
	},

	/**
	 * @param {string} value
	 */
	set mediaText(value) {
		if (typeof value === "string") {
			var values = value.split(",").filter(function(text){
				return !!text;
			});
			var length = this.length = values.length;
			for (var i=0; i<length; i++) {
				this[i] = values[i].trim();
			}
		} else if (value === null) {
			var length = this.length;
			for (var i = 0; i < length; i++) {
				delete this[i];
			}
			this.length = 0;
		}
	},

	/**
	 * @param {string} medium
	 */
	appendMedium: function(medium) {
		if (Array.prototype.indexOf.call(this, medium) === -1) {
			this[this.length] = medium;
			this.length++;
		}
	},

	/**
	 * @param {string} medium
	 */
	deleteMedium: function(medium) {
		var index = Array.prototype.indexOf.call(this, medium);
		if (index !== -1) {
			Array.prototype.splice.call(this, index, 1);
		}
	},

	item: function(index) {
		return this[index] || null;
	},

	toString: function() {
		return this.mediaText;
	}
};






/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#cssmediarule
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSMediaRule
 */
CSSOM.CSSMediaRule = function CSSMediaRule() {
	CSSOM.CSSConditionRule.call(this);
	this.__media = new CSSOM.MediaList();
};

CSSOM.CSSMediaRule.prototype = Object.create(CSSOM.CSSConditionRule.prototype);
CSSOM.CSSMediaRule.prototype.constructor = CSSOM.CSSMediaRule;

Object.setPrototypeOf(CSSOM.CSSMediaRule, CSSOM.CSSConditionRule);

Object.defineProperty(CSSOM.CSSMediaRule.prototype, "type", {
	value: 4,
	writable: false
});

// https://opensource.apple.com/source/WebCore/WebCore-7611.1.21.161.3/css/CSSMediaRule.cpp
Object.defineProperties(CSSOM.CSSMediaRule.prototype, {
  "media": {
    get: function() {
      return this.__media;
    },
    set: function(value) {
      if (typeof value === "string") {
        this.__media.mediaText = value;
      } else {
        this.__media = value;
      }
    },
    configurable: true,
    enumerable: true
  },
  "conditionText": {
    get: function() {
      return this.media.mediaText;
    }
  },
  "cssText": {
    get: function() {
			var values = "";
			var valuesArr = [" {"];
      if (this.cssRules.length) {
        valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
          if (rule.cssText !== "") {
            acc.push(rule.cssText);
          }
          return acc;
        }, []).join("\n  "));
      }
      values = valuesArr.join("\n  ") + "\n}";
      return "@media " + this.media.mediaText + values;
    }
  }
});






/**
 * @constructor
 * @see https://drafts.csswg.org/css-contain-3/
 * @see https://www.w3.org/TR/css-contain-3/
 */
CSSOM.CSSContainerRule = function CSSContainerRule() {
	CSSOM.CSSConditionRule.call(this);
};

CSSOM.CSSContainerRule.prototype = Object.create(CSSOM.CSSConditionRule.prototype);
CSSOM.CSSContainerRule.prototype.constructor = CSSOM.CSSContainerRule;

Object.setPrototypeOf(CSSOM.CSSContainerRule, CSSOM.CSSConditionRule);

Object.defineProperty(CSSOM.CSSContainerRule.prototype, "type", {
	value: 17,
	writable: false
});

Object.defineProperties(CSSOM.CSSContainerRule.prototype, {
  "cssText": {
    get: function() {
			var values = "";
			var valuesArr = [" {"];
      if (this.cssRules.length) {
        valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
          if (rule.cssText !== "") {
            acc.push(rule.cssText);
          }
          return acc;
        }, []).join("\n  "));
      }
      values = valuesArr.join("\n  ") + "\n}";
      return "@container " + this.conditionText + values;
    }
  },
  "containerName": {
      get: function() {
        var parts = this.conditionText.trim().split(/\s+/);
        if (parts.length > 1 && parts[0] !== '(' && !parts[0].startsWith('(')) {
          return parts[0];
        }
        return "";
      }
    },
  "containerQuery": {
      get: function() {
        var parts = this.conditionText.trim().split(/\s+/);
        if (parts.length > 1 && parts[0] !== '(' && !parts[0].startsWith('(')) {
          return parts.slice(1).join(' ');
        }
        return this.conditionText;
      }
    },
});






/**
 * @constructor
 * @see https://drafts.csswg.org/css-conditional-3/#the-csssupportsrule-interface
 */
CSSOM.CSSSupportsRule = function CSSSupportsRule() {
  CSSOM.CSSConditionRule.call(this);
};

CSSOM.CSSSupportsRule.prototype = Object.create(CSSOM.CSSConditionRule.prototype);
CSSOM.CSSSupportsRule.prototype.constructor = CSSOM.CSSSupportsRule;
  
Object.setPrototypeOf(CSSOM.CSSSupportsRule, CSSOM.CSSConditionRule);

Object.defineProperty(CSSOM.CSSSupportsRule.prototype, "type", {
	value: 12,
	writable: false
});

Object.defineProperty(CSSOM.CSSSupportsRule.prototype, "cssText", {
  get: function() {
    var values = "";
    var valuesArr = [" {"];
    if (this.cssRules.length) {
      valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
        if (rule.cssText !== "") {
          acc.push(rule.cssText);
        }
        return acc;
      }, []).join("\n  "));
    }
    values = valuesArr.join("\n  ") + "\n}";
    return "@supports " + this.conditionText + values;
  }
});





/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#cssimportrule
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSImportRule
 */
CSSOM.CSSImportRule = function CSSImportRule() {
	CSSOM.CSSRule.call(this);
	this.__href = "";
	this.__media = new CSSOM.MediaList();
  this.__layerName = null;
  this.__supportsText = null;
	this.__styleSheet = new CSSOM.CSSStyleSheet();
};

CSSOM.CSSImportRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSImportRule.prototype.constructor = CSSOM.CSSImportRule;

Object.setPrototypeOf(CSSOM.CSSImportRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSImportRule.prototype, "type", {
	value: 3,
	writable: false
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "cssText", {
  get: function() {
    var mediaText = this.media.mediaText;
    return "@import url(\"" + this.href.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + "\")" + (this.layerName !== null ? " layer" + (this.layerName && "(" + this.layerName + ")") : "" ) + (this.supportsText ? " supports(" + this.supportsText + ")" : "" ) + (mediaText ? " " + mediaText : "") + ";";
  }
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "href", {
  get: function() {
    return this.__href;
  }
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "media", {
  get: function() {
    return this.__media;
  },
	set: function(value) {
		if (typeof value === "string") {
			this.__media.mediaText = value;
		} else {
			this.__media = value;
		}
	}
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "layerName", {
  get: function() {
    return this.__layerName;
  }
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "supportsText", {
  get: function() {
    return this.__supportsText;
  }
});

Object.defineProperty(CSSOM.CSSImportRule.prototype, "styleSheet", {
  get: function() {
    return this.__styleSheet;
  }
});

/**
 * NON-STANDARD
 * Rule text parser.
 * @param {string} cssText
 */
Object.defineProperty(CSSOM.CSSImportRule.prototype, "parse", {
  value: function(cssText) {
    var i = 0;

    /**
     * @import url(partial.css) screen, handheld;
     *        ||               |
     *        after-import     media
     *         |
     *         url
     */
    var state = '';

    var buffer = '';
    var index;

    var layerRegExp = regexPatterns.layerRegExp;
    var layerRuleNameRegExp = regexPatterns.layerRuleNameRegExp;
    var doubleOrMoreSpacesRegExp = regexPatterns.doubleOrMoreSpacesRegExp;
    
    /**
     * Extracts the content inside supports() handling nested parentheses.
     * @param {string} text - The text to parse
     * @returns {object|null} - {content: string, endIndex: number} or null if not found
     */
    function extractSupportsContent(text) {
      var supportsIndex = text.indexOf('supports(');
      if (supportsIndex !== 0) {
        return null;
      }
      
      var depth = 0;
      var start = supportsIndex + 'supports('.length;
      var i = start;
      
      for (; i < text.length; i++) {
        if (text[i] === '(') {
          depth++;
        } else if (text[i] === ')') {
          if (depth === 0) {
            // Found the closing parenthesis for supports()
            return {
              content: text.slice(start, i),
              endIndex: i
            };
          }
          depth--;
        }
      }
      
      return null; // Unbalanced parentheses
    }

    for (var character; (character = cssText.charAt(i)); i++) {

      switch (character) {
        case ' ':
        case '\t':
        case '\r':
        case '\n':
        case '\f':
          if (state === 'after-import') {
            state = 'url';
          } else {
            buffer += character;
          }
          break;

        case '@':
          if (!state && cssText.indexOf('@import', i) === i) {
            state = 'after-import';
            i += 'import'.length;
            buffer = '';
          }
          break;

        case 'u':
          if (state === 'media') {
            buffer += character;
          }
          if (state === 'url' && cssText.indexOf('url(', i) === i) {
            index = cssText.indexOf(')', i + 1);
            if (index === -1) {
              throw i + ': ")" not found';
            }
            i += 'url('.length;
            var url = cssText.slice(i, index);
            if (url[0] === url[url.length - 1]) {
              if (url[0] === '"' || url[0] === "'") {
                url = url.slice(1, -1);
              }
            }
            this.__href = url;
            i = index;
            state = 'media';
          }
          break;

        case '"':
          if (state === 'after-import' || state === 'url') {
            index = cssText.indexOf('"', i + 1);
            if (!index) {
              throw i + ": '\"' not found";
            }
            this.__href = cssText.slice(i + 1, index);
            i = index;
            state = 'media';
          }
          break;

        case "'":
          if (state === 'after-import' || state === 'url') {
            index = cssText.indexOf("'", i + 1);
            if (!index) {
              throw i + ': "\'" not found';
            }
            this.__href = cssText.slice(i + 1, index);
            i = index;
            state = 'media';
          }
          break;

        case ';':
          if (state === 'media') {
            if (buffer) {
              var bufferTrimmed = buffer.trim();
              
              if (bufferTrimmed.indexOf('layer') === 0) {
                var layerMatch =  bufferTrimmed.match(layerRegExp);

                if (layerMatch) {
                  var layerName = layerMatch[1].trim();

                  if (layerName.match(layerRuleNameRegExp) !== null) {
                    this.__layerName = layerMatch[1].trim();
                    bufferTrimmed = bufferTrimmed.replace(layerRegExp, '')
                      .replace(doubleOrMoreSpacesRegExp, ' ') // Replace double or more spaces with single space
                      .trim();
                  } else {
                    // REVIEW: In the browser, an empty layer() is not processed as a unamed layer
                    // and treats the rest of the string as mediaText, ignoring the parse of supports()
                    if (bufferTrimmed) {
                      this.media.mediaText = bufferTrimmed;
                      return;
                    }
                  }
                } else {
                  this.__layerName = "";
                  bufferTrimmed = bufferTrimmed.substring('layer'.length).trim()
                }
              }

              var supportsResult = extractSupportsContent(bufferTrimmed);

              if (supportsResult) {
                // REVIEW: In the browser, an empty supports() invalidates and ignores the entire @import rule
                this.__supportsText = supportsResult.content.trim();
                // Remove the entire supports(...) from the buffer
                bufferTrimmed = bufferTrimmed.slice(0, 0) + bufferTrimmed.slice(supportsResult.endIndex + 1);
                bufferTrimmed = bufferTrimmed.replace(doubleOrMoreSpacesRegExp, ' ').trim();
              }

              // REVIEW: In the browser, any invalid media is replaced with 'not all'
              if (bufferTrimmed) {
                this.media.mediaText = bufferTrimmed;
              }
            }
          }
          break;

        default:
          if (state === 'media') {
            buffer += character;
          }
          break;
      }
    }
  }
});






/**
 * @constructor
 * @see https://drafts.csswg.org/cssom/#the-cssnamespacerule-interface
 */
CSSOM.CSSNamespaceRule = function CSSNamespaceRule() {
	CSSOM.CSSRule.call(this);
	this.__prefix = "";
	this.__namespaceURI = "";
};

CSSOM.CSSNamespaceRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSNamespaceRule.prototype.constructor = CSSOM.CSSNamespaceRule;

Object.setPrototypeOf(CSSOM.CSSNamespaceRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSNamespaceRule.prototype, "type", {
  value: 10,
  writable: false
});

Object.defineProperty(CSSOM.CSSNamespaceRule.prototype, "cssText", {
  get: function() {
    return "@namespace" + (this.prefix && " " + this.prefix) + " url(\"" + this.namespaceURI + "\");";
  }
});

Object.defineProperty(CSSOM.CSSNamespaceRule.prototype, "prefix", {
  get: function() {
    return this.__prefix;
  }
});

Object.defineProperty(CSSOM.CSSNamespaceRule.prototype, "namespaceURI", {
  get: function() {
    return this.__namespaceURI;
  }
});


/**
 * NON-STANDARD
 * Rule text parser.
 * @param {string} cssText
 */
Object.defineProperty(CSSOM.CSSNamespaceRule.prototype, "parse", {
  value: function(cssText) {
    var newPrefix = "";
    var newNamespaceURI = "";

    // Remove @namespace and trim
    var text = cssText.trim();
    if (text.indexOf('@namespace') === 0) {
      text = text.slice('@namespace'.length).trim();
    }

    // Remove trailing semicolon if present
    if (text.charAt(text.length - 1) === ';') {
      text = text.slice(0, -1).trim();
    }

    // Regex to match valid namespace syntax:
    // 1. [optional prefix] url("...") or [optional prefix] url('...') or [optional prefix] url() or [optional prefix] url(unquoted)
    // 2. [optional prefix] "..." or [optional prefix] '...'
    // The prefix must be a valid CSS identifier (letters, digits, hyphens, underscores, starting with letter or underscore)
    var re = /^(?:([a-zA-Z_][a-zA-Z0-9_-]*)\s+)?(?:url\(\s*(?:(['"])(.*?)\2\s*|([^)]*?))\s*\)|(['"])(.*?)\5)$/;
    var match = text.match(re);

    if (match) {
      // If prefix is present
      if (match[1]) {
        newPrefix = match[1];
      }
      // If url(...) form with quotes
      if (typeof match[3] !== "undefined") {
        newNamespaceURI = match[3];
      }
      // If url(...) form without quotes
      else if (typeof match[4] !== "undefined") {
        newNamespaceURI = match[4].trim();
      }
      // If quoted string form
      else if (typeof match[6] !== "undefined") {
        newNamespaceURI = match[6];
      }

      this.__prefix = newPrefix;
      this.__namespaceURI = newNamespaceURI;
    } else {
      throw new DOMException("Invalid @namespace rule", "InvalidStateError");
    }
  }
});




/**
 * @constructor
 * @see http://dev.w3.org/csswg/cssom/#css-font-face-rule
 */
CSSOM.CSSFontFaceRule = function CSSFontFaceRule() {
	CSSOM.CSSRule.call(this);
	this.__style = new CSSOM.CSSStyleDeclaration();
	this.__style.parentRule = this;
};

CSSOM.CSSFontFaceRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSFontFaceRule.prototype.constructor = CSSOM.CSSFontFaceRule;

Object.setPrototypeOf(CSSOM.CSSFontFaceRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSFontFaceRule.prototype, "type", {
	value: 5,
	writable: false
});

//FIXME
//CSSOM.CSSFontFaceRule.prototype.insertRule = CSSStyleSheet.prototype.insertRule;
//CSSOM.CSSFontFaceRule.prototype.deleteRule = CSSStyleSheet.prototype.deleteRule;

Object.defineProperty(CSSOM.CSSFontFaceRule.prototype, "style", {
	get: function() {
		return this.__style;	
	},
	set: function(value) {
		if (typeof value === "string") {
			this.__style.cssText = value;
		} else {
			this.__style = value;
		}
	}
});

// http://www.opensource.apple.com/source/WebCore/WebCore-955.66.1/css/WebKitCSSFontFaceRule.cpp
Object.defineProperty(CSSOM.CSSFontFaceRule.prototype, "cssText", {
  get: function() {
    return "@font-face {" + (this.style.cssText ? " " + this.style.cssText : "") + " }";
  }
});






/**
 * @constructor
 * @see http://www.w3.org/TR/shadow-dom/#host-at-rule
 * @see http://html5index.org/Shadow%20DOM%20-%20CSSHostRule.html
 * @deprecated This rule was part of early Shadow DOM drafts but was removed in favor of the more flexible :host and :host-context() pseudo-classes in modern CSS for Web Components.
 */
CSSOM.CSSHostRule = function CSSHostRule() {
	CSSOM.CSSRule.call(this);
	this.cssRules = new CSSOM.CSSRuleList();
};

CSSOM.CSSHostRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSHostRule.prototype.constructor = CSSOM.CSSHostRule;

Object.setPrototypeOf(CSSOM.CSSHostRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSHostRule.prototype, "type", {
	value: 1001,
	writable: false
});

//FIXME
//CSSOM.CSSHostRule.prototype.insertRule = CSSStyleSheet.prototype.insertRule;
//CSSOM.CSSHostRule.prototype.deleteRule = CSSStyleSheet.prototype.deleteRule;

Object.defineProperty(CSSOM.CSSHostRule.prototype, "cssText", {
	get: function() {
		var values = "";
		var valuesArr = [" {"];
		if (this.cssRules.length) {
			valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
			if (rule.cssText !== "") {
				acc.push(rule.cssText);
			}
			return acc;
			}, []).join("\n  "));
		}
		values = valuesArr.join("\n  ") + "\n}";
		return "@host" + values;
	}
});






/**
 * @constructor
 * @see http://www.w3.org/TR/shadow-dom/#host-at-rule
 */
CSSOM.CSSStartingStyleRule = function CSSStartingStyleRule() {
	CSSOM.CSSGroupingRule.call(this);
};

CSSOM.CSSStartingStyleRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSStartingStyleRule.prototype.constructor = CSSOM.CSSStartingStyleRule;

Object.setPrototypeOf(CSSOM.CSSStartingStyleRule, CSSOM.CSSGroupingRule);

Object.defineProperty(CSSOM.CSSStartingStyleRule.prototype, "type", {
	value: 1002,
	writable: false
});

//FIXME
//CSSOM.CSSStartingStyleRule.prototype.insertRule = CSSStyleSheet.prototype.insertRule;
//CSSOM.CSSStartingStyleRule.prototype.deleteRule = CSSStyleSheet.prototype.deleteRule;

Object.defineProperty(CSSOM.CSSStartingStyleRule.prototype, "cssText", {
	get: function() {
		var values = "";
		var valuesArr = [" {"];
		if (this.cssRules.length) {
			valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
			if (rule.cssText !== "") {
				acc.push(rule.cssText);
			}
			return acc;
			}, []).join("\n  "));
		}
		values = valuesArr.join("\n  ") + "\n}";
		return "@starting-style" + values;
	}
});






/**
 * @see http://dev.w3.org/csswg/cssom/#the-stylesheet-interface
 */
CSSOM.StyleSheet = function StyleSheet() {
	this.__href = null;
	this.__ownerNode = null;
	this.__title = null;
	this.__media = new CSSOM.MediaList();
	this.__parentStyleSheet = null;
	this.disabled = false;
};

Object.defineProperties(CSSOM.StyleSheet.prototype, {
	type: {
		get: function() {
			return "text/css";
		}
	},
	href: {
		get: function() {
			return this.__href;
		}
	},
	ownerNode: {
		get: function() {
			return this.__ownerNode;
		}
	},
	title: {
		get: function() {
			return this.__title;
		}
	},
	media: {
		get: function() {
			return this.__media;
		},
		set: function(value) {
			if (typeof value === "string") {
				this.__media.mediaText = value;
			} else {
				this.__media = value;
			}
		}
	},
	parentStyleSheet: {
		get: function() {
			return this.__parentStyleSheet;
		}
	}
});





/**
 * @constructor
 * @param {CSSStyleSheetInit} [opts] - CSSStyleSheetInit options.
 * @param {string} [opts.baseURL] - The base URL of the stylesheet.
 * @param {boolean} [opts.disabled] - The disabled attribute of the stylesheet.
 * @param {MediaList | string} [opts.media] - The media attribute of the stylesheet.
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleSheet
 */
CSSOM.CSSStyleSheet = function CSSStyleSheet(opts) {
	CSSOM.StyleSheet.call(this);
	this.__constructed = true;
	this.__cssRules = new CSSOM.CSSRuleList();
	this.__ownerRule = null; 

	if (opts && typeof opts === "object") {
		if (opts.baseURL && typeof opts.baseURL === "string") {
			this.__baseURL = opts.baseURL;
		}
		if (opts.media && typeof opts.media === "string") {
			this.media.mediaText = opts.media;
		}
		if (typeof opts.disabled === "boolean") {
			this.disabled = opts.disabled;
		}
	}
};


CSSOM.CSSStyleSheet.prototype = Object.create(CSSOM.StyleSheet.prototype);
CSSOM.CSSStyleSheet.prototype.constructor = CSSOM.CSSStyleSheet;

Object.setPrototypeOf(CSSOM.CSSStyleSheet, CSSOM.StyleSheet);

Object.defineProperty(CSSOM.CSSStyleSheet.prototype, "cssRules", {
	get: function() {
		return this.__cssRules;
	}
});

Object.defineProperty(CSSOM.CSSStyleSheet.prototype, "rules", {
	get: function() {
		return this.__cssRules;
	}
});

Object.defineProperty(CSSOM.CSSStyleSheet.prototype, "ownerRule", {
	get: function() {
		return this.__ownerRule;
	}
});

/**
 * Used to insert a new rule into the style sheet. The new rule now becomes part of the cascade.
 *
 *   sheet = new Sheet("body {margin: 0}")
 *   sheet.toString()
 *   -> "body{margin:0;}"
 *   sheet.insertRule("img {border: none}", 0)
 *   -> 0
 *   sheet.toString()
 *   -> "img{border:none;}body{margin:0;}"
 *
 * @param {string} rule
 * @param {number} [index=0]
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleSheet-insertRule
 * @return {number} The index within the style sheet's rule collection of the newly inserted rule.
 */
CSSOM.CSSStyleSheet.prototype.insertRule = function(rule, index) {
	if (rule === undefined && index === undefined) {
		errorUtils.throwMissingArguments(this, 'insertRule', this.constructor.name);
	}
	if (index === void 0) {
		index = 0;
	}
	index = Number(index);
	if (index < 0) {
		index = 4294967296 + index;
	}
	if (index > this.cssRules.length) {
		errorUtils.throwIndexError(this, 'insertRule', this.constructor.name, index, this.cssRules.length);
	}
	
	var ruleToParse = String(rule);
	var parseErrors = [];
	var parsedSheet = CSSOM.parse(ruleToParse, undefined, function(err) {
		parseErrors.push(err);
	} );
	if (parsedSheet.cssRules.length !== 1) {
		errorUtils.throwParseError(this, 'insertRule', this.constructor.name, ruleToParse, 'SyntaxError');
	}
	var cssRule = parsedSheet.cssRules[0];
	
	// Helper function to find the last index of a specific rule constructor
	function findLastIndexOfConstructor(rules, constructorName) {
		for (var i = rules.length - 1; i >= 0; i--) {
			if (rules[i].constructor.name === constructorName) {
				return i;
			}
		}
		return -1;
	}
	
	// Helper function to find the first index of a rule that's NOT of specified constructors
	function findFirstNonConstructorIndex(rules, constructorNames) {
		for (var i = 0; i < rules.length; i++) {
			if (constructorNames.indexOf(rules[i].constructor.name) === -1) {
				return i;
			}
		}
		return rules.length;
	}
	
	// Validate rule ordering based on CSS specification
	if (cssRule.constructor.name === 'CSSImportRule') {
		if (this.__constructed === true) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Can't insert @import rules into a constructed stylesheet.",
				'SyntaxError');
		}
		// @import rules cannot be inserted after @layer rules that already exist
		// They can only be inserted at the beginning or after other @import rules
		var firstLayerIndex = findFirstNonConstructorIndex(this.cssRules, ['CSSImportRule']);
		if (firstLayerIndex < this.cssRules.length && this.cssRules[firstLayerIndex].constructor.name === 'CSSLayerStatementRule' && index > firstLayerIndex) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'HierarchyRequestError');
		}
		
		// Also cannot insert after @namespace or other rules
		var firstNonImportIndex = findFirstNonConstructorIndex(this.cssRules, ['CSSImportRule']);
		if (index > firstNonImportIndex && firstNonImportIndex < this.cssRules.length && 
		    this.cssRules[firstNonImportIndex].constructor.name !== 'CSSLayerStatementRule') {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'HierarchyRequestError');
		}
	} else if (cssRule.constructor.name === 'CSSNamespaceRule') {
		// @namespace rules can come after @layer and @import, but before any other rules
		// They cannot come before @import rules
		var firstImportIndex = -1;
		for (var i = 0; i < this.cssRules.length; i++) {
			if (this.cssRules[i].constructor.name === 'CSSImportRule') {
				firstImportIndex = i;
				break;
			}
		}
		var firstNonImportNamespaceIndex = findFirstNonConstructorIndex(this.cssRules, [
			'CSSLayerStatementRule', 
			'CSSImportRule', 
			'CSSNamespaceRule'
		]);
		
		// Cannot insert before @import rules
		if (firstImportIndex !== -1 && index <= firstImportIndex) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'HierarchyRequestError');
		}
		
		// Cannot insert if there are already non-special rules
		if (firstNonImportNamespaceIndex < this.cssRules.length) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'InvalidStateError');
		}
		
		// Cannot insert after other types of rules
		if (index > firstNonImportNamespaceIndex) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'HierarchyRequestError');
		}

		
	} else if (cssRule.constructor.name === 'CSSLayerStatementRule') {
		// @layer statement rules can be inserted anywhere before @import and @namespace
		// No additional restrictions beyond what's already handled
	} else {
		// Any other rule cannot be inserted before @import and @namespace
		var firstNonSpecialRuleIndex = findFirstNonConstructorIndex(this.cssRules, [
			'CSSLayerStatementRule',
			'CSSImportRule',
			'CSSNamespaceRule'
		]);
		
		if (index < firstNonSpecialRuleIndex) {
			errorUtils.throwError(this, 'DOMException',
				"Failed to execute 'insertRule' on '" + this.constructor.name + "': Failed to insert the rule.",
				'HierarchyRequestError');
		}

		if (parseErrors.filter(function(error) { return !error.isNested; }).length !== 0) {
			errorUtils.throwParseError(this, 'insertRule', this.constructor.name, ruleToParse, 'SyntaxError');
		}
	}
	
	cssRule.__parentStyleSheet = this;
	this.cssRules.splice(index, 0, cssRule);
	return index;
};

CSSOM.CSSStyleSheet.prototype.addRule = function(selector, styleBlock, index) {
	if (index === void 0) {
		index = this.cssRules.length;
	}
	this.insertRule(selector + "{" + styleBlock + "}", index);
	return -1;
};

/**
 * Used to delete a rule from the style sheet.
 *
 *   sheet = new Sheet("img{border:none} body{margin:0}")
 *   sheet.toString()
 *   -> "img{border:none;}body{margin:0;}"
 *   sheet.deleteRule(0)
 *   sheet.toString()
 *   -> "body{margin:0;}"
 *
 * @param {number} index within the style sheet's rule list of the rule to remove.
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSStyleSheet-deleteRule
 */
CSSOM.CSSStyleSheet.prototype.deleteRule = function(index) {
	if (index === undefined) {
		errorUtils.throwMissingArguments(this, 'deleteRule', this.constructor.name);
	}
	index = Number(index);
	if (index < 0) {
		index = 4294967296 + index;
	}
	if (index >= this.cssRules.length) {
		errorUtils.throwIndexError(this, 'deleteRule', this.constructor.name, index, this.cssRules.length);
	}
	if (this.cssRules[index]) {		
		if (this.cssRules[index].constructor.name == "CSSNamespaceRule") {
			var shouldContinue = this.cssRules.every(function (rule) {
				return ['CSSImportRule','CSSLayerStatementRule','CSSNamespaceRule'].indexOf(rule.constructor.name) !== -1
			});
			if (!shouldContinue) {
				errorUtils.throwError(this, 'DOMException', "Failed to execute 'deleteRule' on '" + this.constructor.name + "': Failed to delete rule.", "InvalidStateError");
			}
		}
		if (this.cssRules[index].constructor.name == "CSSImportRule") {
			this.cssRules[index].styleSheet.__parentStyleSheet = null;
		}

		this.cssRules[index].__parentStyleSheet = null;
	}
	this.cssRules.splice(index, 1);
};

CSSOM.CSSStyleSheet.prototype.removeRule = function(index) {
	if (index === void 0) {
		index = 0;
	}
	this.deleteRule(index);
};


/**
 * Replaces the rules of a {@link CSSStyleSheet}
 * 
 * @returns a promise
 * @see https://www.w3.org/TR/cssom-1/#dom-cssstylesheet-replace
 */
CSSOM.CSSStyleSheet.prototype.replace = function(text) {
	var _Promise;
	if (this.__globalObject && this.__globalObject['Promise']) {
		_Promise = this.__globalObject['Promise'];
	} else {
		_Promise = Promise;
	}
	var _setTimeout;
	if (this.__globalObject && this.__globalObject['setTimeout']) {
		_setTimeout = this.__globalObject['setTimeout'];
	} else {
		_setTimeout = setTimeout;
	}
	var sheet = this;
	return new _Promise(function (resolve, reject) {
		// If the constructed flag is not set, or the disallow modification flag is set, throw a NotAllowedError DOMException.
		if (!sheet.__constructed || sheet.__disallowModification) {
			reject(errorUtils.createError(sheet, 'DOMException',
				"Failed to execute 'replaceSync' on '" + sheet.constructor.name + "': Not allowed.",
				'NotAllowedError'));
		}
		// Set the disallow modification flag.
		sheet.__disallowModification = true;

		// In parallel, do these steps:
		_setTimeout(function() {
			// Let rules be the result of running parse a stylesheet's contents from text.
			var rules = new CSSOM.CSSRuleList();
			CSSOM.parse(text, { styleSheet: sheet, cssRules: rules });
			// If rules contains one or more @import rules, remove those rules from rules.
			var i = 0;
			while (i < rules.length) {
				if (rules[i].constructor.name === 'CSSImportRule') {
					rules.splice(i, 1);
				} else {
					i++;
				}
			}
			// Set sheet's CSS rules to rules.
			sheet.__cssRules.splice.apply(sheet.__cssRules, [0, sheet.__cssRules.length].concat(rules));
			// Unset sheet’s disallow modification flag.
			delete sheet.__disallowModification;
			// Resolve promise with sheet.
			resolve(sheet);
		})
	});
}

/**
 * Synchronously replaces the rules of a {@link CSSStyleSheet}
 * 
 * @see https://www.w3.org/TR/cssom-1/#dom-cssstylesheet-replacesync
 */
CSSOM.CSSStyleSheet.prototype.replaceSync = function(text) {
	var sheet = this;
	// If the constructed flag is not set, or the disallow modification flag is set, throw a NotAllowedError DOMException.
	if (!sheet.__constructed || sheet.__disallowModification) {
		errorUtils.throwError(sheet, 'DOMException',
			"Failed to execute 'replaceSync' on '" + sheet.constructor.name + "': Not allowed.",
			'NotAllowedError');
	}
	// Let rules be the result of running parse a stylesheet's contents from text.
	var rules = new CSSOM.CSSRuleList();
	CSSOM.parse(text, { styleSheet: sheet, cssRules: rules });
	// If rules contains one or more @import rules, remove those rules from rules.
	var i = 0;
	while (i < rules.length) {
		if (rules[i].constructor.name === 'CSSImportRule') {
			rules.splice(i, 1);
		} else {
			i++;
		}
	}
	// Set sheet's CSS rules to rules.
	sheet.__cssRules.splice.apply(sheet.__cssRules, [0, sheet.__cssRules.length].concat(rules));
}

/**
 * NON-STANDARD
 * @return {string} serialize stylesheet
 */
CSSOM.CSSStyleSheet.prototype.toString = function() {
	var result = "";
	var rules = this.cssRules;
	for (var i=0; i<rules.length; i++) {
		result += rules[i].cssText + "\n";
	}
	return result;
};






/**
 * @constructor
 * @see http://www.w3.org/TR/css3-animations/#DOM-CSSKeyframesRule
 */
CSSOM.CSSKeyframesRule = function CSSKeyframesRule() {
	CSSOM.CSSRule.call(this);
	this.name = '';
	this.cssRules = new CSSOM.CSSRuleList();
	
	// Set up initial indexed access
	this._setupIndexedAccess();
	
	// Override cssRules methods after initial setup, store references as non-enumerable properties
	var self = this;
	var originalPush = this.cssRules.push;
	var originalSplice = this.cssRules.splice;
	
	// Create non-enumerable method overrides
	Object.defineProperty(this.cssRules, 'push', {
		value: function() {
			var result = originalPush.apply(this, arguments);
			self._setupIndexedAccess();
			return result;
		},
		writable: true,
		enumerable: false,
		configurable: true
	});
	
	Object.defineProperty(this.cssRules, 'splice', {
		value: function() {
			var result = originalSplice.apply(this, arguments);
			self._setupIndexedAccess();
			return result;
		},
		writable: true,
		enumerable: false,
		configurable: true
	});
};

CSSOM.CSSKeyframesRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSKeyframesRule.prototype.constructor = CSSOM.CSSKeyframesRule;

Object.setPrototypeOf(CSSOM.CSSKeyframesRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSKeyframesRule.prototype, "type", {
	value: 7,
	writable: false
});

// http://www.opensource.apple.com/source/WebCore/WebCore-955.66.1/css/WebKitCSSKeyframesRule.cpp
Object.defineProperty(CSSOM.CSSKeyframesRule.prototype, "cssText", {
  get: function() {
    var values = "";
	var valuesArr = [" {"];
	if (this.cssRules.length) {
	valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
		if (rule.cssText !== "") {
		acc.push(rule.cssText);
		}
		return acc;
	}, []).join("\n  "));
	}
	values = valuesArr.join("\n  ") + "\n}";
    var cssWideKeywords = ['initial', 'inherit', 'revert', 'revert-layer', 'unset', 'none'];
    var processedName = cssWideKeywords.includes(this.name) ? '"' + this.name + '"' : this.name;
    return "@" + (this._vendorPrefix || '') + "keyframes " + processedName + values;
  }
});

/**
 * Appends a new keyframe rule to the list of keyframes.
 * 
 * @param {string} rule - The keyframe rule string to append (e.g., "50% { opacity: 0.5; }")
 * @see https://www.w3.org/TR/css-animations-1/#dom-csskeyframesrule-appendrule
 */
CSSOM.CSSKeyframesRule.prototype.appendRule = function appendRule(rule) {
	if (arguments.length === 0) {
		errorUtils.throwMissingArguments(this, 'appendRule', 'CSSKeyframesRule');
	}
	
	var parsedRule;
	try {
		// Parse the rule string as a keyframe rule
		var tempStyleSheet = CSSOM.parse("@keyframes temp { " + rule + " }");
		if (tempStyleSheet.cssRules.length > 0 && tempStyleSheet.cssRules[0].cssRules.length > 0) {
			parsedRule = tempStyleSheet.cssRules[0].cssRules[0];
		} else {
			throw new Error("Failed to parse keyframe rule");
		}
	} catch (e) {
		errorUtils.throwParseError(this, 'appendRule', 'CSSKeyframesRule', rule);
	}
	
	parsedRule.__parentRule = this;
	this.cssRules.push(parsedRule);
};

/**
 * Deletes a keyframe rule that matches the specified key.
 * 
 * @param {string} select - The keyframe selector to delete (e.g., "50%", "from", "to")
 * @see https://www.w3.org/TR/css-animations-1/#dom-csskeyframesrule-deleterule
 */
CSSOM.CSSKeyframesRule.prototype.deleteRule = function deleteRule(select) {
	if (arguments.length === 0) {
		errorUtils.throwMissingArguments(this, 'deleteRule', 'CSSKeyframesRule');
	}
	
	var normalizedSelect = this._normalizeKeyText(select);
	
	for (var i = 0; i < this.cssRules.length; i++) {
		var rule = this.cssRules[i];
		if (this._normalizeKeyText(rule.keyText) === normalizedSelect) {
			rule.__parentRule = null;
			this.cssRules.splice(i, 1);
			return;
		}
	}
};

/**
 * Finds and returns the keyframe rule that matches the specified key.
 * When multiple rules have the same key, returns the last one.
 * 
 * @param {string} select - The keyframe selector to find (e.g., "50%", "from", "to")
 * @return {CSSKeyframeRule|null} The matching keyframe rule, or null if not found
 * @see https://www.w3.org/TR/css-animations-1/#dom-csskeyframesrule-findrule
 */
CSSOM.CSSKeyframesRule.prototype.findRule = function findRule(select) {
	if (arguments.length === 0) {
		errorUtils.throwMissingArguments(this, 'findRule', 'CSSKeyframesRule');
	}
	
	var normalizedSelect = this._normalizeKeyText(select);
	
	// Iterate backwards to find the last matching rule
	for (var i = this.cssRules.length - 1; i >= 0; i--) {
		var rule = this.cssRules[i];
		if (this._normalizeKeyText(rule.keyText) === normalizedSelect) {
			return rule;
		}
	}
	
	return null;
};

/**
 * Normalizes keyframe selector text for comparison.
 * Handles "from" -> "0%" and "to" -> "100%" conversions and trims whitespace.
 * 
 * @private
 * @param {string} keyText - The keyframe selector text to normalize
 * @return {string} The normalized keyframe selector text
 */
CSSOM.CSSKeyframesRule.prototype._normalizeKeyText = function _normalizeKeyText(keyText) {
	if (!keyText) return '';
	
	var normalized = keyText.toString().trim().toLowerCase();
	
	// Convert keywords to percentages for comparison
	if (normalized === 'from') {
		return '0%';
	} else if (normalized === 'to') {
		return '100%';
	}
	
	return normalized;
};

/**
 * Makes CSSKeyframesRule iterable over its cssRules.
 * Allows for...of loops and other iterable methods.
 */
if (typeof Symbol !== 'undefined' && Symbol.iterator) {
	CSSOM.CSSKeyframesRule.prototype[Symbol.iterator] = function() {
		var index = 0;
		var cssRules = this.cssRules;
		
		return {
			next: function() {
				if (index < cssRules.length) {
					return { value: cssRules[index++], done: false };
				} else {
					return { done: true };
				}
			}
		};
	};
}

/**
 * Adds indexed getters for direct access to cssRules by index.
 * This enables rule[0], rule[1], etc. access patterns.
 * Works in environments where Proxy is not available (like jsdom).
 */
CSSOM.CSSKeyframesRule.prototype._setupIndexedAccess = function() {
	// Remove any existing indexed properties
	for (var i = 0; i < 1000; i++) { // reasonable upper limit
		if (this.hasOwnProperty(i)) {
			delete this[i];
		} else {
			break;
		}
	}
	
	// Add indexed getters for current cssRules
	for (var i = 0; i < this.cssRules.length; i++) {
		(function(index) {
			Object.defineProperty(this, index, {
				get: function() {
					return this.cssRules[index];
				},
				enumerable: false,
				configurable: true
			});
		}.call(this, i));
	}
	
	// Update length property
	Object.defineProperty(this, 'length', {
		get: function() {
			return this.cssRules.length;
		},
		enumerable: false,
		configurable: true
	});
};









/**
 * @constructor
 * @see http://www.w3.org/TR/css3-animations/#DOM-CSSKeyframeRule
 */
CSSOM.CSSKeyframeRule = function CSSKeyframeRule() {
	CSSOM.CSSRule.call(this);
	this.keyText = '';
	this.__style = new CSSOM.CSSStyleDeclaration();
	this.__style.parentRule = this;
};

CSSOM.CSSKeyframeRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSKeyframeRule.prototype.constructor = CSSOM.CSSKeyframeRule;

Object.setPrototypeOf(CSSOM.CSSKeyframeRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSKeyframeRule.prototype, "type", {
	value: 8,
	writable: false
});

//FIXME
//CSSOM.CSSKeyframeRule.prototype.insertRule = CSSStyleSheet.prototype.insertRule;
//CSSOM.CSSKeyframeRule.prototype.deleteRule = CSSStyleSheet.prototype.deleteRule;

Object.defineProperty(CSSOM.CSSKeyframeRule.prototype, "style", {
	get: function() {
		return this.__style;	
	},
	set: function(value) {
		if (typeof value === "string") {
			this.__style.cssText = value;
		} else {
			this.__style = value;
		}
	}
});

// http://www.opensource.apple.com/source/WebCore/WebCore-955.66.1/css/WebKitCSSKeyframeRule.cpp
Object.defineProperty(CSSOM.CSSKeyframeRule.prototype, "cssText", {
  get: function() {
    return this.keyText + " {" + (this.style.cssText ? " " + this.style.cssText : "") + " }";
  }
});






/**
 * @constructor
 * @see https://developer.mozilla.org/en/CSS/@-moz-document
 */
CSSOM.MatcherList = function MatcherList(){
    this.length = 0;
};

CSSOM.MatcherList.prototype = {

    constructor: CSSOM.MatcherList,

    /**
     * @return {string}
     */
    get matcherText() {
        return Array.prototype.join.call(this, ", ");
    },

    /**
     * @param {string} value
     */
    set matcherText(value) {
        // just a temporary solution, actually it may be wrong by just split the value with ',', because a url can include ','.
        var values = value.split(",");
        var length = this.length = values.length;
        for (var i=0; i<length; i++) {
            this[i] = values[i].trim();
        }
    },

    /**
     * @param {string} matcher
     */
    appendMatcher: function(matcher) {
        if (Array.prototype.indexOf.call(this, matcher) === -1) {
            this[this.length] = matcher;
            this.length++;
        }
    },

    /**
     * @param {string} matcher
     */
    deleteMatcher: function(matcher) {
        var index = Array.prototype.indexOf.call(this, matcher);
        if (index !== -1) {
            Array.prototype.splice.call(this, index, 1);
        }
    }

};






/**
 * @constructor
 * @see https://developer.mozilla.org/en/CSS/@-moz-document
 * @deprecated This rule is a non-standard Mozilla-specific extension and is not part of any official CSS specification.
 */
CSSOM.CSSDocumentRule = function CSSDocumentRule() {
    CSSOM.CSSRule.call(this);
    this.matcher = new CSSOM.MatcherList();
    this.cssRules = new CSSOM.CSSRuleList();
};

CSSOM.CSSDocumentRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSDocumentRule.prototype.constructor = CSSOM.CSSDocumentRule;

Object.setPrototypeOf(CSSOM.CSSDocumentRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSDocumentRule.prototype, "type", {
	value: 10,
	writable: false
});

//FIXME
//CSSOM.CSSDocumentRule.prototype.insertRule = CSSStyleSheet.prototype.insertRule;
//CSSOM.CSSDocumentRule.prototype.deleteRule = CSSStyleSheet.prototype.deleteRule;

Object.defineProperty(CSSOM.CSSDocumentRule.prototype, "cssText", {
  get: function() {
    var cssTexts = [];
    for (var i=0, length=this.cssRules.length; i < length; i++) {
        cssTexts.push(this.cssRules[i].cssText);
    }
    return "@-moz-document " + this.matcher.matcherText + " {" + (cssTexts.length ? "\n  " + cssTexts.join("\n  ") : "") + "\n}";
  }
});






/**
 * @constructor
 * @see http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSValue
 *
 * TODO: add if needed
 */
CSSOM.CSSValue = function CSSValue() {
};

CSSOM.CSSValue.prototype = {
	constructor: CSSOM.CSSValue,

	// @see: http://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSSValue
	set cssText(text) {
		var name = this._getConstructorName();

		throw new Error('DOMException: property "cssText" of "' + name + '" is readonly and can not be replaced with "' + text + '"!');
	},

	get cssText() {
		var name = this._getConstructorName();

		throw new Error('getter "cssText" of "' + name + '" is not implemented!');
	},

	_getConstructorName: function() {
		var s = this.constructor.toString(),
				c = s.match(/function\s([^\(]+)/),
				name = c[1];

		return name;
	}
};






/**
 * @constructor
 * @see http://msdn.microsoft.com/en-us/library/ms537634(v=vs.85).aspx
 *
 */
CSSOM.CSSValueExpression = function CSSValueExpression(token, idx) {
	this._token = token;
	this._idx = idx;
};

CSSOM.CSSValueExpression.prototype = Object.create(CSSOM.CSSValue.prototype);
CSSOM.CSSValueExpression.prototype.constructor = CSSOM.CSSValueExpression;

Object.setPrototypeOf(CSSOM.CSSValueExpression, CSSOM.CSSValue);

/**
 * parse css expression() value
 *
 * @return {Object}
 *         - error:
 *         or
 *         - idx:
 *         - expression:
 *
 * Example:
 *
 * .selector {
 *		zoom: expression(documentElement.clientWidth > 1000 ? '1000px' : 'auto');
 * }
 */
CSSOM.CSSValueExpression.prototype.parse = function() {
	var token = this._token,
			idx = this._idx;

	var character = '',
			expression = '',
			error = '',
			info,
			paren = [];


	for (; ; ++idx) {
		character = token.charAt(idx);

		// end of token
		if (character === '') {
			error = 'css expression error: unfinished expression!';
			break;
		}

		switch(character) {
			case '(':
				paren.push(character);
				expression += character;
				break;

			case ')':
				paren.pop(character);
				expression += character;
				break;

			case '/':
				if ((info = this._parseJSComment(token, idx))) { // comment?
					if (info.error) {
						error = 'css expression error: unfinished comment in expression!';
					} else {
						idx = info.idx;
						// ignore the comment
					}
				} else if ((info = this._parseJSRexExp(token, idx))) { // regexp
					idx = info.idx;
					expression += info.text;
				} else { // other
					expression += character;
				}
				break;

			case "'":
			case '"':
				info = this._parseJSString(token, idx, character);
				if (info) { // string
					idx = info.idx;
					expression += info.text;
				} else {
					expression += character;
				}
				break;

			default:
				expression += character;
				break;
		}

		if (error) {
			break;
		}

		// end of expression
		if (paren.length === 0) {
			break;
		}
	}

	var ret;
	if (error) {
		ret = {
			error: error
		};
	} else {
		ret = {
			idx: idx,
			expression: expression
		};
	}

	return ret;
};


/**
 *
 * @return {Object|false}
 *          - idx:
 *          - text:
 *          or
 *          - error:
 *          or
 *          false
 *
 */
CSSOM.CSSValueExpression.prototype._parseJSComment = function(token, idx) {
	var nextChar = token.charAt(idx + 1),
			text;

	if (nextChar === '/' || nextChar === '*') {
		var startIdx = idx,
				endIdx,
				commentEndChar;

		if (nextChar === '/') { // line comment
			commentEndChar = '\n';
		} else if (nextChar === '*') { // block comment
			commentEndChar = '*/';
		}

		endIdx = token.indexOf(commentEndChar, startIdx + 1 + 1);
		if (endIdx !== -1) {
			endIdx = endIdx + commentEndChar.length - 1;
			text = token.substring(idx, endIdx + 1);
			return {
				idx: endIdx,
				text: text
			};
		} else {
			var error = 'css expression error: unfinished comment in expression!';
			return {
				error: error
			};
		}
	} else {
		return false;
	}
};


/**
 *
 * @return {Object|false}
 *					- idx:
 *					- text:
 *					or 
 *					false
 *
 */
CSSOM.CSSValueExpression.prototype._parseJSString = function(token, idx, sep) {
	var endIdx = this._findMatchedIdx(token, idx, sep),
			text;

	if (endIdx === -1) {
		return false;
	} else {
		text = token.substring(idx, endIdx + sep.length);

		return {
			idx: endIdx,
			text: text
		};
	}
};


/**
 * parse regexp in css expression
 *
 * @return {Object|false}
 *				- idx:
 *				- regExp:
 *				or 
 *				false
 */

/*

all legal RegExp
 
/a/
(/a/)
[/a/]
[12, /a/]

!/a/

+/a/
-/a/
* /a/
/ /a/
%/a/

===/a/
!==/a/
==/a/
!=/a/
>/a/
>=/a/
</a/
<=/a/

&/a/
|/a/
^/a/
~/a/
<</a/
>>/a/
>>>/a/

&&/a/
||/a/
?/a/
=/a/
,/a/

		delete /a/
				in /a/
instanceof /a/
				new /a/
		typeof /a/
			void /a/

*/
CSSOM.CSSValueExpression.prototype._parseJSRexExp = function(token, idx) {
	var before = token.substring(0, idx).replace(/\s+$/, ""),
			legalRegx = [
				/^$/,
				/\($/,
				/\[$/,
				/\!$/,
				/\+$/,
				/\-$/,
				/\*$/,
				/\/\s+/,
				/\%$/,
				/\=$/,
				/\>$/,
				/<$/,
				/\&$/,
				/\|$/,
				/\^$/,
				/\~$/,
				/\?$/,
				/\,$/,
				/delete$/,
				/in$/,
				/instanceof$/,
				/new$/,
				/typeof$/,
				/void$/
			];

	var isLegal = legalRegx.some(function(reg) {
		return reg.test(before);
	});

	if (!isLegal) {
		return false;
	} else {
		var sep = '/';

		// same logic as string
		return this._parseJSString(token, idx, sep);
	}
};


/**
 *
 * find next sep(same line) index in `token`
 *
 * @return {Number}
 *
 */
CSSOM.CSSValueExpression.prototype._findMatchedIdx = function(token, idx, sep) {
	var startIdx = idx,
			endIdx;

	var NOT_FOUND = -1;

	while(true) {
		endIdx = token.indexOf(sep, startIdx + 1);

		if (endIdx === -1) { // not found
			endIdx = NOT_FOUND;
			break;
		} else {
			var text = token.substring(idx + 1, endIdx),
					matched = text.match(/\\+$/);
			if (!matched || matched[0] % 2 === 0) { // not escaped
				break;
			} else {
				startIdx = endIdx;
			}
		}
	}

	// boundary must be in the same line(js sting or regexp)
	var nextNewLineIdx = token.indexOf('\n', idx + 1);
	if (nextNewLineIdx < endIdx) {
		endIdx = NOT_FOUND;
	}


	return endIdx;
};







/**
 * @constructor
 * @see https://drafts.csswg.org/css-cascade-6/#cssscoperule
 */
CSSOM.CSSScopeRule = function CSSScopeRule() {
  CSSOM.CSSGroupingRule.call(this);
  this.__start = null;
  this.__end = null;
};

CSSOM.CSSScopeRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSScopeRule.prototype.constructor = CSSOM.CSSScopeRule;

Object.setPrototypeOf(CSSOM.CSSScopeRule, CSSOM.CSSGroupingRule);

Object.defineProperties(CSSOM.CSSScopeRule.prototype, {
  type: {
    value: 0,
    writable: false,
  },
  cssText: {
    get: function () {
			var values = "";
			var valuesArr = [" {"];
      if (this.cssRules.length) {
        valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
          if (rule.cssText !== "") {
            acc.push(rule.cssText);
          }
          return acc;
        }, []).join("\n  "));
      }
      values = valuesArr.join("\n  ") + "\n}";
      return "@scope" + (this.start ? " (" + this.start + ")" : "") + (this.end ? " to (" + this.end + ")" : "") + values;
    },
    configurable: true,
    enumerable: true,
  },
  start: {
    get: function () {
      return this.__start;
    }
  },
  end: {
    get: function () {
      return this.__end;
    }
  }
});




/**
 * @constructor
 * @see https://drafts.csswg.org/css-cascade-5/#csslayerblockrule
 */
CSSOM.CSSLayerBlockRule = function CSSLayerBlockRule() {
  CSSOM.CSSGroupingRule.call(this);
  this.name = "";
};

CSSOM.CSSLayerBlockRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSLayerBlockRule.prototype.constructor = CSSOM.CSSLayerBlockRule;

Object.setPrototypeOf(CSSOM.CSSLayerBlockRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSLayerBlockRule.prototype, "type", {
	value: 18,
	writable: false
});

Object.defineProperties(CSSOM.CSSLayerBlockRule.prototype, {
  cssText: {
    get: function () {
			var values = "";
			var valuesArr = [" {"];
      if (this.cssRules.length) {
        valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
          if (rule.cssText !== "") {
            acc.push(rule.cssText);
          }
          return acc;
        }, []).join("\n  "));
      }
      values = valuesArr.join("\n  ") + "\n}";
      return "@layer" + (this.name ? " " + this.name : "") + values;
    }
  },
});




/**
 * @constructor
 * @see https://drafts.csswg.org/css-cascade-5/#csslayerstatementrule
 */
CSSOM.CSSLayerStatementRule = function CSSLayerStatementRule() {
  CSSOM.CSSRule.call(this);
  this.nameList = [];
};

CSSOM.CSSLayerStatementRule.prototype = Object.create(CSSOM.CSSRule.prototype);
CSSOM.CSSLayerStatementRule.prototype.constructor = CSSOM.CSSLayerStatementRule;

Object.setPrototypeOf(CSSOM.CSSLayerStatementRule, CSSOM.CSSRule);

Object.defineProperty(CSSOM.CSSLayerStatementRule.prototype, "type", {
	value: 0,
	writable: false
});

Object.defineProperties(CSSOM.CSSLayerStatementRule.prototype, {
  cssText: {
    get: function () {
      return "@layer " + this.nameList.join(", ") + ";";
    }
  },
});





/**
 * @constructor
 * @see https://drafts.csswg.org/cssom/#the-csspagerule-interface
 */
CSSOM.CSSPageRule = function CSSPageRule() {
	CSSOM.CSSGroupingRule.call(this);
	this.__style = new CSSOM.CSSStyleDeclaration();
	this.__style.parentRule = this;
};

CSSOM.CSSPageRule.prototype = Object.create(CSSOM.CSSGroupingRule.prototype);
CSSOM.CSSPageRule.prototype.constructor = CSSOM.CSSPageRule;

Object.setPrototypeOf(CSSOM.CSSPageRule, CSSOM.CSSGroupingRule);

Object.defineProperty(CSSOM.CSSPageRule.prototype, "type", {
	value: 6,
	writable: false
});

Object.defineProperty(CSSOM.CSSPageRule.prototype, "selectorText", {
    get: function() {
        return this.__selectorText;	
    },
    set: function(value) {
        if (typeof value === "string") {
            var trimmedValue = value.trim();
            
            // Empty selector is valid for @page
            if (trimmedValue === '') {
                this.__selectorText = '';
                return;
            }
            
			var atPageRuleSelectorRegExp = regexPatterns.atPageRuleSelectorRegExp;
			var cssCustomIdentifierRegExp = regexPatterns.cssCustomIdentifierRegExp;
            var match = trimmedValue.match(atPageRuleSelectorRegExp);
            if (match) {
				var pageName = match[1] || '';
                var pseudoPages = match[2] || '';

				// Validate page name if present
				if (pageName) {
					// Page name can be an identifier or a string
					if (!cssCustomIdentifierRegExp.test(pageName)) {
						return;
					}
				}
                
                // Validate pseudo-pages if present
                if (pseudoPages) {
                    var pseudos = pseudoPages.split(':').filter(function(p) { return p; });
                    var validPseudos = ['left', 'right', 'first', 'blank'];
                    var allValid = true;
                    for (var j = 0; j < pseudos.length; j++) {
                        if (validPseudos.indexOf(pseudos[j].toLowerCase()) === -1) {
                            allValid = false;
                            break;
                        }
                    }
                    
                    if (!allValid) {
                        return; // Invalid pseudo-page, do nothing
                    }
                }
                
				this.__selectorText = pageName + pseudoPages.toLowerCase();
            }
        }
    }
});

Object.defineProperty(CSSOM.CSSPageRule.prototype, "style", {
	get: function() {
		return this.__style;	
	},
	set: function(value) {
		if (typeof value === "string") {
			this.__style.cssText = value;
		} else {
			this.__style = value;
		}
	}
});

Object.defineProperty(CSSOM.CSSPageRule.prototype, "cssText", {
	get: function() {
        var values = "";
        if (this.cssRules.length) {
            var valuesArr = [" {"];
            this.style.cssText && valuesArr.push(this.style.cssText);
            valuesArr.push(this.cssRules.reduce(function(acc, rule){ 
				if (rule.cssText !== "") {
					acc.push(rule.cssText);
				}
				return acc;
			}, []).join("\n  "));
            values = valuesArr.join("\n  ") + "\n}";
        } else {
            values = " {" + (this.style.cssText ? " " + this.style.cssText : "") + " }";
        }
		return "@page" + (this.selectorText ? " " + this.selectorText : "") + values;
	}
});




/**
 * Parses a CSS string and returns a `CSSStyleSheet` object representing the parsed stylesheet.
 *
 * @param {string} token - The CSS string to parse.
 * @param {object} [opts] - Optional parsing options.
 * @param {object} [opts.globalObject] - An optional global object to prioritize over the window object. Useful on jsdom webplatform tests.
 * @param {Element | ProcessingInstruction} [opts.ownerNode] - The owner node of the stylesheet.
 * @param {CSSRule} [opts.ownerRule] - The owner rule of the stylesheet.
 * @param {CSSOM.CSSStyleSheet} [opts.styleSheet] - Reuse a style sheet instead of creating a new one (e.g. as `parentStyleSheet`)
 * @param {CSSOM.CSSRuleList} [opts.cssRules] - Prepare all rules in this list instead of mutating the style sheet continually
 * @param {function|boolean} [errorHandler] - Optional error handler function or `true` to use `console.error`.
 * @returns {CSSOM.CSSStyleSheet} The parsed `CSSStyleSheet` object.
 */
CSSOM.parse = function parse(token, opts, errorHandler) {
	errorHandler = errorHandler === true ? (console && console.error) : errorHandler;

	var i = 0;

	/**
		"before-selector" or
		"selector" or
		"atRule" or
		"atBlock" or
		"conditionBlock" or
		"before-name" or
		"name" or
		"before-value" or
		"value"
	*/
	var state = "before-selector";

	var index;
	var buffer = "";
	var valueParenthesisDepth = 0;
	var hasUnmatchedQuoteInSelector = false; // Track if current selector has unmatched quote

	var SIGNIFICANT_WHITESPACE = {
		"name": true,
		"before-name": true,
		"selector": true,
		"value": true,
		"value-parenthesis": true,
		"atRule": true,
		"importRule-begin": true,
		"importRule": true,
		"namespaceRule-begin": true,
		"namespaceRule": true,
		"atBlock": true,
		"containerBlock": true,
		"conditionBlock": true,
		"counterStyleBlock": true,
		"propertyBlock": true,
		'documentRule-begin': true,
		"scopeBlock": true,
		"layerBlock": true,
		"pageBlock": true
	};

	var styleSheet;
	if (opts && opts.styleSheet) {
		styleSheet = opts.styleSheet;
	} else {
		if (opts && opts.globalObject && opts.globalObject.CSSStyleSheet) {
			styleSheet = new opts.globalObject.CSSStyleSheet();
		} else {
			styleSheet = new CSSOM.CSSStyleSheet();
		}
		styleSheet.__constructed = false;
	}

	var topScope;
	if (opts && opts.cssRules) {
		topScope = { cssRules: opts.cssRules };
	} else {
		topScope = styleSheet;
	}

	if (opts && opts.ownerNode) {
		styleSheet.__ownerNode = opts.ownerNode;
		var ownerNodeMedia = opts.ownerNode.media || (opts.ownerNode.getAttribute && opts.ownerNode.getAttribute("media"));
		if (ownerNodeMedia) {
			styleSheet.media.mediaText = ownerNodeMedia;
		}
		var ownerNodeTitle = opts.ownerNode.title || (opts.ownerNode.getAttribute && opts.ownerNode.getAttribute("title"));
		if (ownerNodeTitle) {
			styleSheet.__title = ownerNodeTitle;
		}
	}

	if (opts && opts.ownerRule) {
		styleSheet.__ownerRule = opts.ownerRule;
	}

	// @type CSSStyleSheet|CSSMediaRule|CSSContainerRule|CSSSupportsRule|CSSFontFaceRule|CSSKeyframesRule|CSSDocumentRule
	var currentScope = topScope;

	// @type CSSMediaRule|CSSContainerRule|CSSSupportsRule|CSSKeyframesRule|CSSDocumentRule
	var parentRule;

	var ancestorRules = [];
	var prevScope;

	var name, priority = "", styleRule, mediaRule, containerRule, counterStyleRule, propertyRule, supportsRule, importRule, fontFaceRule, keyframesRule, documentRule, hostRule, startingStyleRule, scopeRule, pageRule, layerBlockRule, layerStatementRule, nestedSelectorRule, namespaceRule;

	// Track defined namespace prefixes for validation
	var definedNamespacePrefixes = {};

	// Track which rules have been added
	var ruleIdCounter = 0;
	var addedToParent = {};
	var addedToTopScope = {};
	var addedToCurrentScope = {};

	// Helper to get unique ID for tracking rules
	function getRuleId(rule) {
		if (!rule.__parseId) {
			rule.__parseId = ++ruleIdCounter;
		}
		return rule.__parseId;
	}

	// Cache last validation boundary position
	// to avoid rescanning the entire token string for each at-rule
	var lastValidationBoundary = 0;

	// Pre-compile validation regexes for common at-rules
	var validationRegexCache = {};
	function getValidationRegex(atRuleKey) {
		if (!validationRegexCache[atRuleKey]) {
			var sourceRuleRegExp = atRuleKey === "@import" ? forwardImportRuleValidationRegExp : forwardRuleValidationRegExp;
			validationRegexCache[atRuleKey] = new RegExp(atRuleKey + sourceRuleRegExp.source, sourceRuleRegExp.flags);
		}
		return validationRegexCache[atRuleKey];
	}

	// Import regex patterns from shared module
	var atKeyframesRegExp = regexPatterns.atKeyframesRegExp;
	var beforeRulePortionRegExp = regexPatterns.beforeRulePortionRegExp;
	var beforeRuleValidationRegExp = regexPatterns.beforeRuleValidationRegExp;
	var forwardRuleValidationRegExp = regexPatterns.forwardRuleValidationRegExp;
	var forwardImportRuleValidationRegExp = regexPatterns.forwardImportRuleValidationRegExp;

	// Pre-compile regexBefore to avoid creating it on every validateAtRule call
	var regexBefore = new RegExp(beforeRulePortionRegExp.source, beforeRulePortionRegExp.flags);
	var forwardRuleClosingBraceRegExp = regexPatterns.forwardRuleClosingBraceRegExp;
	var forwardRuleSemicolonAndOpeningBraceRegExp = regexPatterns.forwardRuleSemicolonAndOpeningBraceRegExp;
	var cssCustomIdentifierRegExp = regexPatterns.cssCustomIdentifierRegExp;
	var startsWithCombinatorRegExp = regexPatterns.startsWithCombinatorRegExp;
	var atPageRuleSelectorRegExp = regexPatterns.atPageRuleSelectorRegExp;
	var startsWithHexEscapeRegExp = regexPatterns.startsWithHexEscapeRegExp;
	var identStartCharRegExp = regexPatterns.identStartCharRegExp;
	var identCharRegExp = regexPatterns.identCharRegExp;
	var specialCharsNeedEscapeRegExp = regexPatterns.specialCharsNeedEscapeRegExp;
	var combinatorOrSeparatorRegExp = regexPatterns.combinatorOrSeparatorRegExp;
	var afterHexEscapeSeparatorRegExp = regexPatterns.afterHexEscapeSeparatorRegExp;
	var trailingSpaceSeparatorRegExp = regexPatterns.trailingSpaceSeparatorRegExp;
	var endsWithHexEscapeRegExp = regexPatterns.endsWithHexEscapeRegExp;
	var attributeSelectorContentRegExp = regexPatterns.attributeSelectorContentRegExp;
	var pseudoElementRegExp = regexPatterns.pseudoElementRegExp;
	var invalidCombinatorLtGtRegExp = regexPatterns.invalidCombinatorLtGtRegExp;
	var invalidCombinatorDoubleGtRegExp = regexPatterns.invalidCombinatorDoubleGtRegExp;
	var consecutiveCombinatorsRegExp = regexPatterns.consecutiveCombinatorsRegExp;
	var invalidSlottedRegExp = regexPatterns.invalidSlottedRegExp;
	var invalidPartRegExp = regexPatterns.invalidPartRegExp;
	var invalidCueRegExp = regexPatterns.invalidCueRegExp;
	var invalidCueRegionRegExp = regexPatterns.invalidCueRegionRegExp;
	var invalidNestingPattern = regexPatterns.invalidNestingPattern;
	var emptyPseudoClassRegExp = regexPatterns.emptyPseudoClassRegExp;
	var whitespaceNormalizationRegExp = regexPatterns.whitespaceNormalizationRegExp;
	var newlineRemovalRegExp = regexPatterns.newlineRemovalRegExp;
	var whitespaceAndDotRegExp = regexPatterns.whitespaceAndDotRegExp;
	var declarationOrOpenBraceRegExp = regexPatterns.declarationOrOpenBraceRegExp;
	var ampersandRegExp = regexPatterns.ampersandRegExp;
	var hexEscapeSequenceRegExp = regexPatterns.hexEscapeSequenceRegExp;
	var attributeCaseFlagRegExp = regexPatterns.attributeCaseFlagRegExp;
	var prependedAmpersandRegExp = regexPatterns.prependedAmpersandRegExp;
	var openBraceGlobalRegExp = regexPatterns.openBraceGlobalRegExp;
	var closeBraceGlobalRegExp = regexPatterns.closeBraceGlobalRegExp;
	var scopePreludeSplitRegExp = regexPatterns.scopePreludeSplitRegExp;
	var leadingWhitespaceRegExp = regexPatterns.leadingWhitespaceRegExp;
	var doubleQuoteRegExp = regexPatterns.doubleQuoteRegExp;
	var backslashRegExp = regexPatterns.backslashRegExp;

	/**
	 * Searches for the first occurrence of a CSS at-rule statement terminator (`;` or `}`) 
	 * that is not inside a brace block within the given string. Mimics the behavior of a 
	 * regular expression match for such terminators, including any trailing whitespace.
	 * @param {string} str - The string to search for at-rule statement terminators.
	 * @returns {object | null} {0: string, index: number} or null if no match is found.
	 */
	function atRulesStatemenRegExpES5Alternative(ruleSlice) {
		for (var i = 0; i < ruleSlice.length; i++) {
			var char = ruleSlice[i];

			if (char === ';' || char === '}') {
				// Simulate negative lookbehind: check if there is a { before this position
				var sliceBefore = ruleSlice.substring(0, i);
				var openBraceIndex = sliceBefore.indexOf('{');

				if (openBraceIndex === -1) {
					// No { found before, so we treat it as a valid match
					var match = char;
					var j = i + 1;

					while (j < ruleSlice.length && /\s/.test(ruleSlice[j])) {
						match += ruleSlice[j];
						j++;
					}

					var matchObj = [match];
					matchObj.index = i;
					matchObj.input = ruleSlice;
					return matchObj;
				}
			}
		}

		return null;
	}

	/**
	 * Finds the first balanced block (including nested braces) in the string, starting from fromIndex.
	 * Returns an object similar to RegExp.prototype.match output.
	 * @param {string} str - The string to search.
	 * @param {number} [fromIndex=0] - The index to start searching from.
	 * @returns {object|null} - { 0: matchedString, index: startIndex, input: str } or null if not found.
	 */
	function matchBalancedBlock(str, fromIndex) {
		fromIndex = fromIndex || 0;
		var openIndex = str.indexOf('{', fromIndex);
		if (openIndex === -1) return null;
		var depth = 0;
		for (var i = openIndex; i < str.length; i++) {
			if (str[i] === '{') {
				depth++;
			} else if (str[i] === '}') {
				depth--;
				if (depth === 0) {
					var matchedString = str.slice(openIndex, i + 1);
					return {
						0: matchedString,
						index: openIndex,
						input: str
					};
				}
			}
		}
		return null;
	}

	/**
	 * Advances the index `i` to skip over a balanced block of curly braces in the given string.
	 * This is typically used to ignore the contents of a CSS rule block.
	 *
	 * @param {number} i - The current index in the string to start searching from.
	 * @param {string} str - The string containing the CSS code.
	 * @param {number} fromIndex - The index in the string where the balanced block search should begin.
	 * @returns {number} The updated index after skipping the balanced block.
	 */
	function ignoreBalancedBlock(i, str, fromIndex) {
		var ruleClosingMatch = matchBalancedBlock(str, fromIndex);
		if (ruleClosingMatch) {
			var ignoreRange = ruleClosingMatch.index + ruleClosingMatch[0].length;
			i += ignoreRange;
			if (token.charAt(i) === '}') {
				i -= 1;
			}
		} else {
			i += str.length;
		}
		return i;
	}

	/**
	 * Parses the scope prelude and extracts start and end selectors.
	 * @param {string} preludeContent - The scope prelude content (without @scope keyword)
	 * @returns {object} Object with startSelector and endSelector properties
	 */
	function parseScopePrelude(preludeContent) {
		var parts = preludeContent.split(scopePreludeSplitRegExp);

		// Restore the parentheses that were consumed by the split
		if (parts.length === 2) {
			parts[0] = parts[0] + ')';
			parts[1] = '(' + parts[1];
		}

		var hasStart = parts[0] &&
			parts[0].charAt(0) === '(' &&
			parts[0].charAt(parts[0].length - 1) === ')';
		var hasEnd = parts[1] &&
			parts[1].charAt(0) === '(' &&
			parts[1].charAt(parts[1].length - 1) === ')';

		// Handle case: @scope to (<end>)
		var hasOnlyEnd = !hasStart &&
			!hasEnd &&
			parts[0].indexOf('to (') === 0 &&
			parts[0].charAt(parts[0].length - 1) === ')';

		var startSelector = '';
		var endSelector = '';

		if (hasStart) {
			startSelector = parts[0].slice(1, -1).trim();
		}
		if (hasEnd) {
			endSelector = parts[1].slice(1, -1).trim();
		}
		if (hasOnlyEnd) {
			endSelector = parts[0].slice(4, -1).trim();
		}

		return {
			startSelector: startSelector,
			endSelector: endSelector,
			hasStart: hasStart,
			hasEnd: hasEnd,
			hasOnlyEnd: hasOnlyEnd
		};
	};

	/**
	 * Checks if a selector contains pseudo-elements.
	 * @param {string} selector - The CSS selector to check
	 * @returns {boolean} True if the selector contains pseudo-elements
	 */
	function hasPseudoElement(selector) {
		// Match only double-colon (::) pseudo-elements
		// Also match legacy single-colon pseudo-elements: :before, :after, :first-line, :first-letter
		// These must NOT be followed by alphanumeric characters (to avoid matching :before-x or similar)
		return pseudoElementRegExp.test(selector);
	};

	/**
	 * Validates balanced parentheses, brackets, and quotes in a selector.
	 * 
	 * @param {string} selector - The CSS selector to validate
	 * @param {boolean} trackAttributes - Whether to track attribute selector context
	 * @param {boolean} useStack - Whether to use a stack for parentheses (needed for nested validation)
	 * @returns {boolean} True if the syntax is valid (all brackets, parentheses, and quotes are balanced)
	 */
	function validateBalancedSyntax(selector, trackAttributes, useStack) {
		var parenDepth = 0;
		var bracketDepth = 0;
		var inSingleQuote = false;
		var inDoubleQuote = false;
		var inAttr = false;
		var stack = useStack ? [] : null;

		for (var i = 0; i < selector.length; i++) {
			var char = selector[i];

			// Handle escape sequences - skip hex escapes or simple escapes
			if (char === '\\') {
				var escapeLen = getEscapeSequenceLength(selector, i);
				if (escapeLen > 0) {
					i += escapeLen - 1; // -1 because loop will increment
					continue;
				}
			}

			if (inSingleQuote) {
				if (char === "'") {
					inSingleQuote = false;
				}
			} else if (inDoubleQuote) {
				if (char === '"') {
					inDoubleQuote = false;
				}
			} else if (trackAttributes && inAttr) {
				if (char === "]") {
					inAttr = false;
				} else if (char === "'") {
					inSingleQuote = true;
				} else if (char === '"') {
					inDoubleQuote = true;
				}
			} else {
				if (trackAttributes && char === "[") {
					inAttr = true;
				} else if (char === "'") {
					inSingleQuote = true;
				} else if (char === '"') {
					inDoubleQuote = true;
				} else if (char === '(') {
					if (useStack) {
						stack.push("(");
					} else {
						parenDepth++;
					}
				} else if (char === ')') {
					if (useStack) {
						if (!stack.length || stack.pop() !== "(") {
							return false;
						}
					} else {
						parenDepth--;
						if (parenDepth < 0) {
							return false;
						}
					}
				} else if (char === '[') {
					bracketDepth++;
				} else if (char === ']') {
					bracketDepth--;
					if (bracketDepth < 0) {
						return false;
					}
				}
			}
		}

		// Check if everything is balanced
		if (useStack) {
			return stack.length === 0 && bracketDepth === 0 && !inSingleQuote && !inDoubleQuote && !inAttr;
		} else {
			return parenDepth === 0 && bracketDepth === 0 && !inSingleQuote && !inDoubleQuote;
		}
	};

	/**
	 * Checks for basic syntax errors in selectors (mismatched parentheses, brackets, quotes).
	 * @param {string} selector - The CSS selector to check
	 * @returns {boolean} True if there are syntax errors
	 */
	function hasBasicSyntaxError(selector) {
		return !validateBalancedSyntax(selector, false, false);
	};

	/**
	 * Checks for invalid combinator patterns in selectors.
	 * @param {string} selector - The CSS selector to check
	 * @returns {boolean} True if the selector contains invalid combinators
	 */
	function hasInvalidCombinators(selector) {
		// Check for invalid combinator patterns:
		// - <> (not a valid combinator)
		// - >> (deep descendant combinator, deprecated and invalid)
		// - Multiple consecutive combinators like >>, >~, etc.
		if (invalidCombinatorLtGtRegExp.test(selector)) return true;
		if (invalidCombinatorDoubleGtRegExp.test(selector)) return true;
		// Check for other invalid consecutive combinator patterns
		if (consecutiveCombinatorsRegExp.test(selector)) return true;
		return false;
	};

	/**
	 * Checks for invalid pseudo-like syntax (function calls without proper pseudo prefix).
	 * @param {string} selector - The CSS selector to check
	 * @returns {boolean} True if the selector contains invalid pseudo-like syntax
	 */
	function hasInvalidPseudoSyntax(selector) {
		// Check for specific known pseudo-elements used without : or :: prefix
		// Examples: slotted(div), part(name), cue(selector)
		// These are ONLY valid as ::slotted(), ::part(), ::cue()
		var invalidPatterns = [
			invalidSlottedRegExp,
			invalidPartRegExp,
			invalidCueRegExp,
			invalidCueRegionRegExp
		];

		for (var i = 0; i < invalidPatterns.length; i++) {
			if (invalidPatterns[i].test(selector)) {
				return true;
			}
		}
		return false;
	};

	/**
	 * Checks for invalid nesting selector (&) usage.
	 * The & selector cannot be directly followed by a type selector without a delimiter.
	 * Valid: &.class, &#id, &[attr], &:hover, &::before, & div, &>div
	 * Invalid: &div, &span
	 * @param {string} selector - The CSS selector to check
	 * @returns {boolean} True if the selector contains invalid & usage
	 */
	function hasInvalidNestingSelector(selector) {
		// Check for & followed directly by a letter (type selector) without any delimiter
		// This regex matches & followed by a letter (start of type selector) that's not preceded by an escape
		// We need to exclude valid cases like &.class, &#id, &[attr], &:pseudo, &::pseudo, & (with space), &>
		return invalidNestingPattern.test(selector);
	};

	/**
	 * Checks if an at-rule can be nested based on parent chain validation.
	 * Used for at-rules like `@counter-style`, `@property` and `@font-face` rules that can only be nested inside
	 * `CSSScopeRule` or `CSSConditionRule` without `CSSStyleRule` in parent chain.
	 * @returns {boolean} `true` if nesting is allowed, `false` otherwise
	 */
	function canAtRuleBeNested() {
		if (currentScope === topScope) {
			return true; // Top-level is always allowed
		}

		var hasStyleRuleInChain = false;
		var hasValidParent = false;

		// Check currentScope
		if (currentScope.constructor.name === 'CSSStyleRule') {
			hasStyleRuleInChain = true;
		} else if (currentScope instanceof CSSOM.CSSScopeRule || currentScope instanceof CSSOM.CSSConditionRule) {
			hasValidParent = true;
		}

		// Check ancestorRules for CSSStyleRule
		if (!hasStyleRuleInChain) {
			for (var j = 0; j < ancestorRules.length; j++) {
				if (ancestorRules[j].constructor.name === 'CSSStyleRule') {
					hasStyleRuleInChain = true;
					break;
				}
				if (ancestorRules[j] instanceof CSSOM.CSSScopeRule || ancestorRules[j] instanceof CSSOM.CSSConditionRule) {
					hasValidParent = true;
				}
			}
		}

		// Allow nesting if we have a valid parent and no style rule in the chain
		return hasValidParent && !hasStyleRuleInChain;
	}

	function validateAtRule(atRuleKey, validCallback, cannotBeNested) {
		var isValid = false;
		// Use cached regex instead of creating new one each time
		var ruleRegExp = getValidationRegex(atRuleKey);
		//  Only slice what we need for validation (max 100 chars)
		// since we only check match at position 0
		var lookAheadLength = Math.min(100, token.length - i);
		var ruleSlice = token.slice(i, i + lookAheadLength);
		// Not all rules can be nested, if the rule cannot be nested and is in the root scope, do not perform the check
		var shouldPerformCheck = cannotBeNested && currentScope !== topScope ? false : true;
		// First, check if there is no invalid characters just after the at-rule
		if (shouldPerformCheck && ruleSlice.search(ruleRegExp) === 0) {
			// Only scan from the last known validation boundary
			var searchStart = Math.max(0, lastValidationBoundary);
			var beforeSlice = token.slice(searchStart, i);
			
			// Use pre-compiled regex instead of creating new one each time
			var matches = beforeSlice.match(regexBefore);
			var lastI = matches ? searchStart + beforeSlice.lastIndexOf(matches[matches.length - 1]) : searchStart;
			var toCheckSlice = token.slice(lastI, i);
			// Check if we don't have any invalid in the portion before the `at-rule` and the closest allowed character
			var checkedSlice = toCheckSlice.search(beforeRuleValidationRegExp);
			if (checkedSlice === 0) {
				isValid = true;
				// Update the validation boundary cache to this position
				lastValidationBoundary = lastI;
			}
		}

		// Additional validation for @scope rule
		if (isValid && atRuleKey === "@scope") {
			var openBraceIndex = ruleSlice.indexOf('{');
			if (openBraceIndex !== -1) {
				// Extract the rule prelude (everything between the at-rule and {)
				var rulePrelude = ruleSlice.slice(0, openBraceIndex).trim();

				// Skip past at-rule keyword and whitespace
				var preludeContent = rulePrelude.slice("@scope".length).trim();

				if (preludeContent.length > 0) {
					// Parse the scope prelude
					var parsedScopePrelude = parseScopePrelude(preludeContent);
					var startSelector = parsedScopePrelude.startSelector;
					var endSelector = parsedScopePrelude.endSelector;
					var hasStart = parsedScopePrelude.hasStart;
					var hasEnd = parsedScopePrelude.hasEnd;
					var hasOnlyEnd = parsedScopePrelude.hasOnlyEnd;

					// Validation rules for @scope:
					// 1. Empty selectors in parentheses are invalid: @scope () {} or @scope (.a) to () {}
					if ((hasStart && startSelector === '') || (hasEnd && endSelector === '') || (hasOnlyEnd && endSelector === '')) {
						isValid = false;
					}
					// 2. Pseudo-elements are invalid in scope selectors
					else if ((startSelector && hasPseudoElement(startSelector)) || (endSelector && hasPseudoElement(endSelector))) {
						isValid = false;
					}
					// 3. Basic syntax errors (mismatched parens, brackets, quotes)
					else if ((startSelector && hasBasicSyntaxError(startSelector)) || (endSelector && hasBasicSyntaxError(endSelector))) {
						isValid = false;
					}
					// 4. Invalid combinator patterns
					else if ((startSelector && hasInvalidCombinators(startSelector)) || (endSelector && hasInvalidCombinators(endSelector))) {
						isValid = false;
					}
					// 5. Invalid pseudo-like syntax (function without : or :: prefix)
					else if ((startSelector && hasInvalidPseudoSyntax(startSelector)) || (endSelector && hasInvalidPseudoSyntax(endSelector))) {
						isValid = false;
					}
					// 6. Invalid structure (no proper parentheses found when prelude is not empty)
					else if (!hasStart && !hasOnlyEnd) {
						isValid = false;
					}
				}
				// Empty prelude (@scope {}) is valid
			}
		}

		if (isValid && atRuleKey === "@page") {
			var openBraceIndex = ruleSlice.indexOf('{');
			if (openBraceIndex !== -1) {
				// Extract the rule prelude (everything between the at-rule and {)
				var rulePrelude = ruleSlice.slice(0, openBraceIndex).trim();

				// Skip past at-rule keyword and whitespace
				var preludeContent = rulePrelude.slice("@page".length).trim();

				if (preludeContent.length > 0) {
					var trimmedValue = preludeContent.trim();

					// Empty selector is valid for @page
					if (trimmedValue !== '') {
						// Parse @page selectorText for page name and pseudo-pages
						// Valid formats:
						// - (empty - no name, no pseudo-page)
						// - :left, :right, :first, :blank (pseudo-page only)
						// - named (named page only)
						// - named:first (named page with single pseudo-page)
						// - named:first:left (named page with multiple pseudo-pages)
						var match = trimmedValue.match(atPageRuleSelectorRegExp);
						if (match) {
							var pageName = match[1] || '';
							var pseudoPages = match[2] || '';

							// Validate page name if present
							if (pageName) {
								if (!cssCustomIdentifierRegExp.test(pageName)) {
									isValid = false;
								}
							}

							// Validate pseudo-pages if present
							if (pseudoPages) {
								var pseudos = pseudoPages.split(':').filter(function (p) { return p; });
								var validPseudos = ['left', 'right', 'first', 'blank'];
								var allValid = true;
								for (var j = 0; j < pseudos.length; j++) {
									if (validPseudos.indexOf(pseudos[j].toLowerCase()) === -1) {
										allValid = false;
										break;
									}
								}

								if (!allValid) {
									isValid = false;
								}
							}
						} else {
							isValid = false;
						}
					}

				}
			}
		}

		if (!isValid) {
			// If it's invalid the browser will simply ignore the entire invalid block
			// Use regex to find the closing brace of the invalid rule

			// Regex used above is not ES5 compliant. Using alternative.
			// var ruleStatementMatch = ruleSlice.match(atRulesStatemenRegExp); //
			var ruleStatementMatch = atRulesStatemenRegExpES5Alternative(ruleSlice);

			// If it's a statement inside a nested rule, ignore only the statement
			if (ruleStatementMatch && currentScope !== topScope) {
				var ignoreEnd = ruleStatementMatch[0].indexOf(";");
				i += ruleStatementMatch.index + ignoreEnd;
				return;
			}

			// Check if there's a semicolon before the invalid at-rule and the first opening brace
			if (atRuleKey === "@layer") {
				var ruleSemicolonAndOpeningBraceMatch = ruleSlice.match(forwardRuleSemicolonAndOpeningBraceRegExp);
				if (ruleSemicolonAndOpeningBraceMatch && ruleSemicolonAndOpeningBraceMatch[1] === ";") {
					// Ignore the rule block until the semicolon
					i += ruleSemicolonAndOpeningBraceMatch.index + ruleSemicolonAndOpeningBraceMatch[0].length;
					state = "before-selector";
					return;
				}
			}

			// Ignore the entire rule block (if it's a statement it should ignore the statement plus the next block)
			i = ignoreBalancedBlock(i, ruleSlice);
			state = "before-selector";
		} else {
			validCallback.call(this);
		}
	}

	// Helper functions for looseSelectorValidator
	// Defined outside to avoid recreation on every validation call

	/**
	 * Check if character is a valid identifier start
	 * @param {string} c - Character to check
	 * @returns {boolean}
	 */
	function isIdentStart(c) {
		return /[a-zA-Z_\u00A0-\uFFFF]/.test(c);
	}

	/**
	 * Check if character is a valid identifier character
	 * @param {string} c - Character to check
	 * @returns {boolean}
	 */
	function isIdentChar(c) {
		return /[a-zA-Z0-9_\u00A0-\uFFFF\-]/.test(c);
	}

	/**
	 * Helper function to validate CSS selector syntax without regex backtracking.
	 * Iteratively parses the selector string to identify valid components.
	 * 
	 * Supports:
	 * - Escaped characters (e.g., .class\!, #id\@name)
	 * - Namespace selectors (ns|element, *|element, |element)
	 * - All standard CSS selectors (class, ID, type, attribute, pseudo, etc.)
	 * - Combinators (>, +, ~, whitespace)
	 * - Nesting selector (&)
	 * 
	 * This approach eliminates exponential backtracking by using explicit character-by-character
	 * parsing instead of nested quantifiers in regex.
	 * 
	 * @param {string} selector - The selector to validate
	 * @returns {boolean} - True if valid selector syntax
	 */
	function looseSelectorValidator(selector) {
		if (!selector || selector.length === 0) {
			return false;
		}

		var i = 0;
		var len = selector.length;
		var hasMatchedComponent = false;

		// Helper: Skip escaped character (backslash + hex escape or any char)
		function skipEscape() {
			if (i < len && selector[i] === '\\') {
				var escapeLen = getEscapeSequenceLength(selector, i);
				if (escapeLen > 0) {
					i += escapeLen; // Skip entire escape sequence
					return true;
				}
			}
			return false;
		}

		// Helper: Parse identifier (with possible escapes)
		function parseIdentifier() {
			var start = i;
			while (i < len) {
				if (skipEscape()) {
					continue;
				} else if (isIdentChar(selector[i])) {
					i++;
				} else {
					break;
				}
			}
			return i > start;
		}

		// Helper: Parse namespace prefix (optional)
		function parseNamespace() {
			var start = i;

			// Match: *| or identifier| or |
			if (i < len && selector[i] === '*') {
				i++;
			} else if (i < len && (isIdentStart(selector[i]) || selector[i] === '\\')) {
				parseIdentifier();
			}

			if (i < len && selector[i] === '|') {
				i++;
				return true;
			}

			// Rollback if no pipe found
			i = start;
			return false;
		}

		// Helper: Parse pseudo-class/element arguments (with balanced parens)
		function parsePseudoArgs() {
			if (i >= len || selector[i] !== '(') {
				return false;
			}

			i++; // Skip opening paren
			var depth = 1;
			var inString = false;
			var stringChar = '';

			while (i < len && depth > 0) {
				var c = selector[i];

				if (c === '\\' && i + 1 < len) {
					i += 2; // Skip escaped character
				} else if (!inString && (c === '"' || c === '\'')) {
					inString = true;
					stringChar = c;
					i++;
				} else if (inString && c === stringChar) {
					inString = false;
					i++;
				} else if (!inString && c === '(') {
					depth++;
					i++;
				} else if (!inString && c === ')') {
					depth--;
					i++;
				} else {
					i++;
				}
			}

			return depth === 0;
		}

		// Main parsing loop
		while (i < len) {
			var matched = false;
			var start = i;

			// Skip whitespace
			while (i < len && /\s/.test(selector[i])) {
				i++;
			}
			if (i > start) {
				hasMatchedComponent = true;
				continue;
			}

			// Match combinators: >, +, ~
			if (i < len && /[>+~]/.test(selector[i])) {
				i++;
				hasMatchedComponent = true;
				// Skip trailing whitespace
				while (i < len && /\s/.test(selector[i])) {
					i++;
				}
				continue;
			}

			// Match nesting selector: &
			if (i < len && selector[i] === '&') {
				i++;
				hasMatchedComponent = true;
				matched = true;
			}
			// Match class selector: .identifier
			else if (i < len && selector[i] === '.') {
				i++;
				if (parseIdentifier()) {
					hasMatchedComponent = true;
					matched = true;
				}
			}
			// Match ID selector: #identifier
			else if (i < len && selector[i] === '#') {
				i++;
				if (parseIdentifier()) {
					hasMatchedComponent = true;
					matched = true;
				}
			}
			// Match pseudo-class/element: :identifier or ::identifier
			else if (i < len && selector[i] === ':') {
				i++;
				if (i < len && selector[i] === ':') {
					i++; // Pseudo-element
				}
				if (parseIdentifier()) {
					parsePseudoArgs(); // Optional arguments
					hasMatchedComponent = true;
					matched = true;
				}
			}
			// Match attribute selector: [...]
			else if (i < len && selector[i] === '[') {
				i++;
				var depth = 1;
				while (i < len && depth > 0) {
					if (selector[i] === '\\') {
						i += 2;
					} else if (selector[i] === '\'') {
						i++;
						while (i < len && selector[i] !== '\'') {
							if (selector[i] === '\\') i += 2;
							else i++;
						}
						if (i < len) i++; // Skip closing quote
					} else if (selector[i] === '"') {
						i++;
						while (i < len && selector[i] !== '"') {
							if (selector[i] === '\\') i += 2;
							else i++;
						}
						if (i < len) i++; // Skip closing quote
					} else if (selector[i] === '[') {
						depth++;
						i++;
					} else if (selector[i] === ']') {
						depth--;
						i++;
					} else {
						i++;
					}
				}
				if (depth === 0) {
					hasMatchedComponent = true;
					matched = true;
				}
			}
			// Match type selector with optional namespace: [namespace|]identifier
			else if (i < len && (isIdentStart(selector[i]) || selector[i] === '\\' || selector[i] === '*' || selector[i] === '|')) {
				parseNamespace(); // Optional namespace prefix

				if (i < len && selector[i] === '*') {
					i++; // Universal selector
					hasMatchedComponent = true;
					matched = true;
				} else if (i < len && (isIdentStart(selector[i]) || selector[i] === '\\')) {
					if (parseIdentifier()) {
						hasMatchedComponent = true;
						matched = true;
					}
				}
			}

			// If no match found, invalid selector
			if (!matched && i === start) {
				return false;
			}
		}

		return hasMatchedComponent;
	}

	/**
	 * Validates a basic CSS selector, allowing for deeply nested balanced parentheses in pseudo-classes.
	 * This function replaces the previous basicSelectorRegExp.
	 * 
	 * This function matches:
	 * - Type selectors (e.g., `div`, `span`)
	 * - Universal selector (`*`)
	 * - Namespace selectors (e.g., `*|div`, `custom|div`, `|div`)
	 * - ID selectors (e.g., `#header`, `#a\ b`, `#åèiöú`)
	 * - Class selectors (e.g., `.container`, `.a\ b`, `.åèiöú`)
	 * - Attribute selectors (e.g., `[type="text"]`)
	 * - Pseudo-classes and pseudo-elements (e.g., `:hover`, `::before`, `:nth-child(2)`)
	 * - Pseudo-classes with nested parentheses, including cases where parentheses are nested inside arguments,
	 *   such as `:has(.sel:nth-child(3n))`
	 * - The parent selector (`&`)
	 * - Combinators (`>`, `+`, `~`) with optional whitespace
	 * - Whitespace (descendant combinator)
	 *
	 * Unicode and escape sequences are allowed in identifiers.
	 *
	 * @param {string} selector
	 * @returns {boolean}
	 */
	function basicSelectorValidator(selector) {
		// Guard against extremely long selectors to prevent potential regex performance issues
		// Reasonable selectors are typically under 1000 characters
		if (selector.length > 10000) {
			return false;
		}

		// Validate balanced syntax with attribute tracking and stack-based parentheses matching
		if (!validateBalancedSyntax(selector, true, true)) {
			return false;
		}

		// Check for invalid combinator patterns
		if (hasInvalidCombinators(selector)) {
			return false;
		}

		// Check for invalid pseudo-like syntax
		if (hasInvalidPseudoSyntax(selector)) {
			return false;
		}

		// Check for invalid nesting selector (&) usage
		if (hasInvalidNestingSelector(selector)) {
			return false;
		}

		// Check for invalid pseudo-class usage with quoted strings
		// Pseudo-classes like :lang(), :dir(), :nth-*() should not accept quoted strings
		// Using iterative parsing instead of regex to avoid exponential backtracking
		var noQuotesPseudos = ['lang', 'dir', 'nth-child', 'nth-last-child', 'nth-of-type', 'nth-last-of-type'];

		for (var idx = 0; idx < selector.length; idx++) {
			// Look for pseudo-class/element start
			if (selector[idx] === ':') {
				var pseudoStart = idx;
				idx++;

				// Skip second colon for pseudo-elements
				if (idx < selector.length && selector[idx] === ':') {
					idx++;
				}

				// Extract pseudo name
				var nameStart = idx;
				while (idx < selector.length && /[a-zA-Z0-9\-]/.test(selector[idx])) {
					idx++;
				}

				if (idx === nameStart) {
					continue; // No name found
				}

				var pseudoName = selector.substring(nameStart, idx).toLowerCase();

				// Check if this pseudo has arguments
				if (idx < selector.length && selector[idx] === '(') {
					idx++;
					var contentStart = idx;
					var depth = 1;

					// Find matching closing paren (handle nesting)
					while (idx < selector.length && depth > 0) {
						if (selector[idx] === '\\') {
							idx += 2; // Skip escaped character
						} else if (selector[idx] === '(') {
							depth++;
							idx++;
						} else if (selector[idx] === ')') {
							depth--;
							idx++;
						} else {
							idx++;
						}
					}

					if (depth === 0) {
						var pseudoContent = selector.substring(contentStart, idx - 1);

						// Check if this pseudo should not have quoted strings
						for (var j = 0; j < noQuotesPseudos.length; j++) {
							if (pseudoName === noQuotesPseudos[j] && /['"]/.test(pseudoContent)) {
								return false;
							}
						}
					}
				}
			}
		}

		// Use the iterative validator to avoid regex backtracking issues
		return looseSelectorValidator(selector);
	}

	/**
	 * Regular expression to match CSS pseudo-classes with arguments.
	 *
	 * Matches patterns like `:pseudo-class(argument)`, capturing the pseudo-class name and its argument.
	 *
	 * Capture groups:
	 *   1. The pseudo-class name (letters and hyphens).
	 *   2. The argument inside the parentheses (can contain nested parentheses, quoted strings, and other characters.).
	 *
	 * Global flag (`g`) is used to find all matches in the input string.
	 *
	 * Example matches:
	 *   - :nth-child(2n+1)
	 *   - :has(.sel:nth-child(3n))
	 *   - :not(".foo, .bar")
	 *
	 * REPLACED WITH FUNCTION to avoid exponential backtracking.
	 */

	/**
	 * Extract pseudo-classes with arguments from a selector using iterative parsing.
	 * Replaces the previous globalPseudoClassRegExp to avoid exponential backtracking.
	 * 
	 * Handles:
	 * - Regular content without parentheses or quotes
	 * - Single-quoted strings
	 * - Double-quoted strings  
	 * - Nested parentheses (arbitrary depth)
	 * 
	 * @param {string} selector - The CSS selector to parse
	 * @returns {Array} Array of matches, each with: [fullMatch, pseudoName, pseudoArgs, startIndex]
	 */
	function extractPseudoClasses(selector) {
		var matches = [];

		for (var i = 0; i < selector.length; i++) {
			// Look for pseudo-class start (single or double colon)
			if (selector[i] === ':') {
				var pseudoStart = i;
				i++;

				// Skip second colon for pseudo-elements (::)
				if (i < selector.length && selector[i] === ':') {
					i++;
				}

				// Extract pseudo name
				var nameStart = i;
				while (i < selector.length && /[a-zA-Z\-]/.test(selector[i])) {
					i++;
				}

				if (i === nameStart) {
					continue; // No name found
				}

				var pseudoName = selector.substring(nameStart, i);

				// Check if this pseudo has arguments
				if (i < selector.length && selector[i] === '(') {
					i++;
					var argsStart = i;
					var depth = 1;
					var inSingleQuote = false;
					var inDoubleQuote = false;

					// Find matching closing paren (handle nesting and strings)
					while (i < selector.length && depth > 0) {
						var ch = selector[i];

						if (ch === '\\') {
							i += 2; // Skip escaped character
						} else if (ch === "'" && !inDoubleQuote) {
							inSingleQuote = !inSingleQuote;
							i++;
						} else if (ch === '"' && !inSingleQuote) {
							inDoubleQuote = !inDoubleQuote;
							i++;
						} else if (ch === '(' && !inSingleQuote && !inDoubleQuote) {
							depth++;
							i++;
						} else if (ch === ')' && !inSingleQuote && !inDoubleQuote) {
							depth--;
							i++;
						} else {
							i++;
						}
					}

					if (depth === 0) {
						var pseudoArgs = selector.substring(argsStart, i - 1);
						var fullMatch = selector.substring(pseudoStart, i);

						// Store match in same format as regex: [fullMatch, pseudoName, pseudoArgs, startIndex]
						matches.push([fullMatch, pseudoName, pseudoArgs, pseudoStart]);
					}

					// Move back one since loop will increment
					i--;
				}
			}
		}

		return matches;
	}

	/**
	 * Parses a CSS selector string and splits it into parts, handling nested parentheses.
	 *
	 * This function is useful for splitting selectors that may contain nested function-like
	 * syntax (e.g., :not(.foo, .bar)), ensuring that commas inside parentheses do not split
	 * the selector.
	 *
	 * @param {string} selector - The CSS selector string to parse.
	 * @returns {string[]} An array of selector parts, split by top-level commas, with whitespace trimmed.
	 */
	function parseAndSplitNestedSelectors(selector) {
		var depth = 0;           // Track parenthesis nesting depth
		var buffer = "";         // Accumulate characters for current selector part
		var parts = [];          // Array of split selector parts
		var inSingleQuote = false; // Track if we're inside single quotes
		var inDoubleQuote = false; // Track if we're inside double quotes
		var i, char;

		for (i = 0; i < selector.length; i++) {
			char = selector.charAt(i);

			// Handle escape sequences - skip them entirely
			if (char === '\\' && i + 1 < selector.length) {
				buffer += char;
				i++;
				buffer += selector.charAt(i);
				continue;
			}

			// Handle single quote strings
			if (char === "'" && !inDoubleQuote) {
				inSingleQuote = !inSingleQuote;
				buffer += char;
			}
			// Handle double quote strings
			else if (char === '"' && !inSingleQuote) {
				inDoubleQuote = !inDoubleQuote;
				buffer += char;
			}
			// Process characters outside of quoted strings
			else if (!inSingleQuote && !inDoubleQuote) {
				if (char === '(') {
					// Entering a nested level (e.g., :is(...))
					depth++;
					buffer += char;
				} else if (char === ')') {
					// Exiting a nested level
					depth--;
					buffer += char;
				} else if (char === ',' && depth === 0) {
					// Found a top-level comma separator - split here
					// Note: escaped commas (\,) are already handled above
					if (buffer.trim()) {
						parts.push(buffer.trim());
					}
					buffer = "";
				} else {
					// Regular character - add to buffer
					buffer += char;
				}
			}
			// Characters inside quoted strings - add to buffer
			else {
				buffer += char;
			}
		}

		// Add any remaining content in buffer as the last part
		var trimmed = buffer.trim();
		if (trimmed) {
			// Preserve trailing space if selector ends with hex escape
			var endsWithHexEscape = endsWithHexEscapeRegExp.test(buffer);
			parts.push(endsWithHexEscape ? buffer.replace(leadingWhitespaceRegExp, '') : trimmed);
		}

		return parts;
	}

	/**
	 * Validates a CSS selector string, including handling of nested selectors within certain pseudo-classes.
	 *
	 * This function checks if the provided selector is valid according to the rules defined by
	 * `basicSelectorValidator`. For pseudo-classes that accept selector lists (such as :not, :is, :has, :where),
	 * it recursively validates each nested selector using the same validation logic.
	 *
	 * @param {string} selector - The CSS selector string to validate.
	 * @returns {boolean} Returns `true` if the selector is valid, otherwise `false`.
	 */

	// Cache to store validated selectors (previously a ES6 Map, now an ES5-compliant object)
	var validatedSelectorsCache = {};

	// Only pseudo-classes that accept selector lists should recurse
	var selectorListPseudoClasses = {
		'not': true,
		'is': true,
		'has': true,
		'where': true
	};

	function validateSelector(selector) {
		if (validatedSelectorsCache.hasOwnProperty(selector)) {
			return validatedSelectorsCache[selector];
		}

		// Use function-based parsing to extract pseudo-classes (avoids backtracking)
		var pseudoClassMatches = extractPseudoClasses(selector);

		for (var j = 0; j < pseudoClassMatches.length; j++) {
			var pseudoClass = pseudoClassMatches[j][1];
			if (selectorListPseudoClasses.hasOwnProperty(pseudoClass)) {
				var nestedSelectors = parseAndSplitNestedSelectors(pseudoClassMatches[j][2]);

				// Check if ANY selector in the list contains & (nesting selector)
				// If so, skip validation for the entire selector list since & will be replaced at runtime
				var hasAmpersand = false;
				for (var k = 0; k < nestedSelectors.length; k++) {
					if (ampersandRegExp.test(nestedSelectors[k])) {
						hasAmpersand = true;
						break;
					}
				}

				// If any selector has &, skip validation for this entire pseudo-class
				if (hasAmpersand) {
					continue;
				}

				// Otherwise, validate each selector normally
				for (var i = 0; i < nestedSelectors.length; i++) {
					var nestedSelector = nestedSelectors[i];
					if (!validatedSelectorsCache.hasOwnProperty(nestedSelector)) {
						var nestedSelectorValidation = validateSelector(nestedSelector);
						validatedSelectorsCache[nestedSelector] = nestedSelectorValidation;
						if (!nestedSelectorValidation) {
							validatedSelectorsCache[selector] = false;
							return false;
						}
					} else if (!validatedSelectorsCache[nestedSelector]) {
						validatedSelectorsCache[selector] = false;
						return false;
					}
				}
			}
		}

		var basicSelectorValidation = basicSelectorValidator(selector);
		validatedSelectorsCache[selector] = basicSelectorValidation;

		return basicSelectorValidation;
	}

	/**
	 * Validates namespace selectors by checking if the namespace prefix is defined.
	 * 
	 * @param {string} selector - The CSS selector to validate
	 * @returns {boolean} Returns true if the namespace is valid, false otherwise
	 */
	function validateNamespaceSelector(selector) {
		// Check if selector contains a namespace prefix
		// We need to ignore pipes inside attribute selectors
		var pipeIndex = -1;
		var inAttr = false;
		var inSingleQuote = false;
		var inDoubleQuote = false;

		for (var i = 0; i < selector.length; i++) {
			var char = selector[i];

			// Handle escape sequences - skip hex escapes or simple escapes
			if (char === '\\') {
				var escapeLen = getEscapeSequenceLength(selector, i);
				if (escapeLen > 0) {
					i += escapeLen - 1; // -1 because loop will increment
					continue;
				}
			}

			if (inSingleQuote) {
				if (char === "'") {
					inSingleQuote = false;
				}
			} else if (inDoubleQuote) {
				if (char === '"') {
					inDoubleQuote = false;
				}
			} else if (inAttr) {
				if (char === "]") {
					inAttr = false;
				} else if (char === "'") {
					inSingleQuote = true;
				} else if (char === '"') {
					inDoubleQuote = true;
				}
			} else {
				if (char === "[") {
					inAttr = true;
				} else if (char === "|" && !inAttr) {
					// This is a namespace separator, not an attribute operator
					pipeIndex = i;
					break;
				}
			}
		}

		if (pipeIndex === -1) {
			return true; // No namespace, always valid
		}

		var namespacePrefix = selector.substring(0, pipeIndex);

		// Universal namespace (*|) and default namespace (|) are always valid
		if (namespacePrefix === '*' || namespacePrefix === '') {
			return true;
		}

		// Check if the custom namespace prefix is defined
		return definedNamespacePrefixes.hasOwnProperty(namespacePrefix);
	}

	/**
	 * Normalizes escape sequences in a selector to match browser behavior.
	 * Decodes escape sequences and re-encodes them in canonical form.
	 * 
	 * @param {string} selector - The selector to normalize
	 * @returns {string} Normalized selector
	 */
	function normalizeSelectorEscapes(selector) {
		var result = '';
		var i = 0;
		var nextChar = '';
		
		// Track context for identifier boundaries
		var inIdentifier = false;
		var inAttribute = false;
		var attributeDepth = 0;
		var needsEscapeForIdent = false;
		var lastWasHexEscape = false;
		
		while (i < selector.length) {
			var char = selector[i];
			
			// Track attribute selector context
			if (char === '[' && !inAttribute) {
				inAttribute = true;
				attributeDepth = 1;
				result += char;
				i++;
				needsEscapeForIdent = false;
				inIdentifier = false;
				lastWasHexEscape = false;
				continue;
			}
			
			if (inAttribute) {
				if (char === '[') attributeDepth++;
				if (char === ']') {
					attributeDepth--;
					if (attributeDepth === 0) inAttribute = false;
				}
				// Don't normalize escapes inside attribute selectors
				if (char === '\\' && i + 1 < selector.length) {
					var escapeLen = getEscapeSequenceLength(selector, i);
					result += selector.substr(i, escapeLen);
					i += escapeLen;
				} else {
					result += char;
					i++;
				}
				lastWasHexEscape = false;
				continue;
			}
			
			// Handle escape sequences
			if (char === '\\') {
				var escapeLen = getEscapeSequenceLength(selector, i);
				if (escapeLen > 0) {
					var escapeSeq = selector.substr(i, escapeLen);
					var decoded = decodeEscapeSequence(escapeSeq);
					var wasHexEscape = startsWithHexEscapeRegExp.test(escapeSeq);
					var hadTerminatingSpace = wasHexEscape && escapeSeq[escapeLen - 1] === ' ';
					nextChar = selector[i + escapeLen] || '';
					
					// Check if this character needs escaping
					var needsEscape = false;
					var useHexEscape = false;
					
					if (needsEscapeForIdent) {
						// At start of identifier (after . # or -)
						// Digits must be escaped, letters/underscore/_/- don't need escaping
						if (isDigit(decoded)) {
							needsEscape = true;
							useHexEscape = true;
						} else if (decoded === '-') {
							// Dash at identifier start: keep escaped if it's the only character,
							// otherwise it can be decoded
							var remainingSelector = selector.substring(i + escapeLen);
							var hasMoreIdentChars = remainingSelector && identCharRegExp.test(remainingSelector[0]);
							needsEscape = !hasMoreIdentChars;
						} else if (!identStartCharRegExp.test(decoded)) {
							needsEscape = true;
						}
					} else {
						if (specialCharsNeedEscapeRegExp.test(decoded)) {
							needsEscape = true;
						}
					}
					
					if (needsEscape) {
						if (useHexEscape) {
							// Use normalized hex escape
							var codePoint = decoded.charCodeAt(0);
							var hex = codePoint.toString(16);
							result += '\\' + hex;
							// Add space if next char could continue the hex sequence, 
							// or if at end of selector (to disambiguate the escape)
							if (isHexDigit(nextChar) || !nextChar || afterHexEscapeSeparatorRegExp.test(nextChar)) {
								result += ' ';
								lastWasHexEscape = false;
							} else {
								lastWasHexEscape = true;
							}
						} else {
							// Use simple character escape
							result += '\\' + decoded;
							lastWasHexEscape = false;
						}
					} else {
						// No escape needed, use the character directly
						// But if previous was hex escape (without terminating space) and this is alphanumeric, add space
						if (lastWasHexEscape && !hadTerminatingSpace && isAlphanumeric(decoded)) {
							result += ' ';
						}
						result += decoded;
						// Preserve terminating space at end of selector (when followed by non-ident char)
						if (hadTerminatingSpace && (!nextChar || afterHexEscapeSeparatorRegExp.test(nextChar))) {
							result += ' ';
						}
						lastWasHexEscape = false;
					}
					
					i += escapeLen;
					// After processing escape, check if we're still needing ident validation
					// Only stay in needsEscapeForIdent state if decoded was '-'
					needsEscapeForIdent = needsEscapeForIdent && decoded === '-';
					inIdentifier = true;
					continue;
				}
			}
			
			// Handle regular characters
			if (char === '.' || char === '#') {
				result += char;
				needsEscapeForIdent = true;
				inIdentifier = false;
				lastWasHexEscape = false;
				i++;
			} else if (char === '-' && needsEscapeForIdent) {
				// Dash after . or # - next char must be valid ident start or digit (which needs escaping)
				result += char;
				needsEscapeForIdent = true;
				lastWasHexEscape = false;
				i++;
			} else if (isDigit(char) && needsEscapeForIdent) {
				// Digit at identifier start must be hex escaped
				var codePoint = char.charCodeAt(0);
				var hex = codePoint.toString(16);
				result += '\\' + hex;
				nextChar = selector[i + 1] || '';
				// Add space if next char could continue the hex sequence,
				// or if at end of selector (to disambiguate the escape)
				if (isHexDigit(nextChar) || !nextChar || afterHexEscapeSeparatorRegExp.test(nextChar)) {
					result += ' ';
					lastWasHexEscape = false;
				} else {
					lastWasHexEscape = true;
				}
				needsEscapeForIdent = false;
				inIdentifier = true;
				i++;
			} else if (char === ':' || combinatorOrSeparatorRegExp.test(char)) {
				// Combinators, separators, and pseudo-class markers reset identifier state
				// Preserve trailing space from hex escape
				if (!(char === ' ' && lastWasHexEscape && result[result.length - 1] === ' ')) {
					result += char;
				}
				needsEscapeForIdent = false;
				inIdentifier = false;
				lastWasHexEscape = false;
				i++;
			} else if (isLetter(char) && lastWasHexEscape) {
				// Letter after hex escape needs a space separator
				result += ' ' + char;
				needsEscapeForIdent = false;
				inIdentifier = true;
				lastWasHexEscape = false;
				i++;
			} else if (char === ' ' && lastWasHexEscape) {
				// Trailing space - keep it if at end or before non-ident char
				nextChar = selector[i + 1] || '';
				if (!nextChar || trailingSpaceSeparatorRegExp.test(nextChar)) {
					result += char;
				}
				needsEscapeForIdent = false;
				inIdentifier = false;
				lastWasHexEscape = false;
				i++;
			} else {
				result += char;
				needsEscapeForIdent = false;
				inIdentifier = true;
				lastWasHexEscape = false;
				i++;
			}
		}
		
		return result;
	}

	/**
	 * Helper function to decode all escape sequences in a string.
	 * 
	 * @param {string} str - The string to decode
	 * @returns {string} The decoded string
	 */
	function decodeEscapeSequencesInString(str) {
		var result = '';
		for (var i = 0; i < str.length; i++) {
			if (str[i] === '\\' && i + 1 < str.length) {
				// Get the escape sequence length
				var escapeLen = getEscapeSequenceLength(str, i);
				if (escapeLen > 0) {
					var escapeSeq = str.substr(i, escapeLen);
					var decoded = decodeEscapeSequence(escapeSeq);
					result += decoded;
					i += escapeLen - 1; // -1 because loop will increment
					continue;
				}
			}
			result += str[i];
		}
		return result;
	}

	/**
	 * Decodes a CSS escape sequence to its character value.
	 * 
	 * @param {string} escapeSeq - The escape sequence (including backslash)
	 * @returns {string} The decoded character
	 */
	function decodeEscapeSequence(escapeSeq) {
		if (escapeSeq.length < 2 || escapeSeq[0] !== '\\') {
			return escapeSeq;
		}
		
		var content = escapeSeq.substring(1);
		
		// Check if it's a hex escape
		var hexMatch = content.match(hexEscapeSequenceRegExp);
		if (hexMatch) {
			var codePoint = parseInt(hexMatch[1], 16);
			// Handle surrogate pairs for code points > 0xFFFF
			if (codePoint > 0xFFFF) {
				// Convert to surrogate pair
				codePoint -= 0x10000;
				var high = 0xD800 + (codePoint >> 10);
				var low = 0xDC00 + (codePoint & 0x3FF);
				return String.fromCharCode(high, low);
			}
			return String.fromCharCode(codePoint);
		}
		
		// Simple escape - return the character after backslash
		return content[0] || '';
	}

	/**
	 * Normalizes attribute selectors by ensuring values are properly quoted with double quotes.
	 * Examples:
	 *   [attr=value] -> [attr="value"]
	 *   [attr="value"] -> [attr="value"] (unchanged)
	 *   [attr='value'] -> [attr="value"] (converted to double quotes)
	 * 
	 * @param {string} selector - The selector to normalize
	 * @returns {string|null} Normalized selector, or null if invalid
	 */
	function normalizeAttributeSelectors(selector) {
		var result = '';
		var i = 0;
		
		while (i < selector.length) {
			// Look for attribute selector start
			if (selector[i] === '[') {
				result += '[';
				i++;
				
				var attrContent = '';
				var depth = 1;
				
				// Find the closing bracket, handling nested brackets and escapes
				while (i < selector.length && depth > 0) {
					if (selector[i] === '\\' && i + 1 < selector.length) {
						attrContent += selector.substring(i, i + 2);
						i += 2;
						continue;
					}
					if (selector[i] === '[') depth++;
					if (selector[i] === ']') {
						depth--;
						if (depth === 0) break;
					}
					attrContent += selector[i];
					i++;
				}
				
				// Normalize the attribute content
				var normalized = normalizeAttributeContent(attrContent);
				if (normalized === null) {
					// Invalid attribute selector (e.g., unclosed quote)
					return null;
				}
				result += normalized;
				if (i < selector.length && selector[i] === ']') {
					result += ']';
					i++;
				}
			} else {
				result += selector[i];
				i++;
			}
		}
		
		return result;
	}

	/**
	 * Processes a quoted attribute value by checking for proper closure and decoding escape sequences.
	 * @param {string} trimmedValue - The quoted value (with quotes)
	 * @param {string} quoteChar - The quote character ('"' or "'")
	 * @param {string} attrName - The attribute name
	 * @param {string} operator - The attribute operator
	 * @param {string} flag - Optional case-sensitivity flag
	 * @returns {string|null} Normalized attribute content, or null if invalid
	 */
	function processQuotedAttributeValue(trimmedValue, quoteChar, attrName, operator, flag) {
		// Check if the closing quote is properly closed (not escaped)
		if (trimmedValue.length < 2) {
			return null; // Too short
		}
		// Find the actual closing quote (not escaped)
		var i = 1;
		var foundClose = false;
		while (i < trimmedValue.length) {
			if (trimmedValue[i] === '\\' && i + 1 < trimmedValue.length) {
				// Skip escape sequence
				var escapeLen = getEscapeSequenceLength(trimmedValue, i);
				i += escapeLen;
				continue;
			}
			if (trimmedValue[i] === quoteChar) {
				// Found closing quote
				foundClose = (i === trimmedValue.length - 1);
				break;
			}
			i++;
		}
		if (!foundClose) {
			return null; // Unclosed quote - invalid
		}
		// Extract inner value and decode escape sequences
		var innerValue = trimmedValue.slice(1, -1);
		var decodedValue = decodeEscapeSequencesInString(innerValue);
		// If decoded value contains quotes, we need to escape them
		var escapedValue = decodedValue.replace(doubleQuoteRegExp, '\\"');
		return attrName + operator + '"' + escapedValue + '"' + (flag ? ' ' + flag : '');
	}

	/**
	 * Normalizes the content inside an attribute selector.
	 * @param {string} content - The content between [ and ]
	 * @returns {string} Normalized content, or null if invalid
	 */
	function normalizeAttributeContent(content) {
		// Match: attribute-name [operator] [value] [flag]
		var match = content.match(attributeSelectorContentRegExp);
		
		if (!match) {
			// No operator (e.g., [disabled]) or malformed - return as is
			return content;
		}
		
		var attrName = match[1];
		var operator = match[2];
		var valueAndFlag = match[3].trim(); // Trim here instead of in regex
		
		// Check if there's a case-sensitivity flag (i or s) at the end
		var flagMatch = valueAndFlag.match(attributeCaseFlagRegExp);
		var value = flagMatch ? flagMatch[1] : valueAndFlag;
		var flag = flagMatch ? flagMatch[2] : '';
		
		// Check for unclosed quotes - this makes the selector invalid
		var trimmedValue = value.trim();
		var firstChar = trimmedValue[0];
		
		if (firstChar === '"') {
			return processQuotedAttributeValue(trimmedValue, '"', attrName, operator, flag);
		}
		
		if (firstChar === "'") {
			return processQuotedAttributeValue(trimmedValue, "'", attrName, operator, flag);
		}
		
		// Check for unescaped special characters in unquoted values
		// Escaped special characters are valid (e.g., \` is valid, but ` is not)
		var hasUnescapedSpecialChar = false;
		for (var i = 0; i < trimmedValue.length; i++) {
			var char = trimmedValue[i];
			if (char === '\\' && i + 1 < trimmedValue.length) {
				// Skip the entire escape sequence
				var escapeLen = getEscapeSequenceLength(trimmedValue, i);
				if (escapeLen > 0) {
					i += escapeLen - 1; // -1 because loop will increment
					continue;
				}
			}
			// Check if this is an unescaped special character
			if (specialCharsNeedEscapeRegExp.test(char)) {
				hasUnescapedSpecialChar = true;
				break;
			}
		}
		
		if (hasUnescapedSpecialChar) {
			return null; // Unescaped special characters not allowed in unquoted attribute values
		}
		
		// Decode escape sequences in the value before quoting
		// Inside quotes, special characters don't need escaping
		var decodedValue = decodeEscapeSequencesInString(trimmedValue);
		
		// If the decoded value contains double quotes, escape them for the output
		// (since we're using double quotes as delimiters)
		var escapedValue = decodedValue.replace(backslashRegExp, '\\\\').replace(doubleQuoteRegExp, '\\"');
		
		// Unquoted value - add double quotes with decoded and re-escaped content
		return attrName + operator + '"' + escapedValue + '"' + (flag ? ' ' + flag : '');
	}

	/**
	 * Processes a CSS selector text 
	 * 
	 * @param {string} selectorText - The CSS selector text to process
	 * @returns {string} The processed selector text with normalized whitespace and invalid selectors removed
	 */
	function processSelectorText(selectorText) {
		// Normalize whitespace first
		var normalized = selectorText.replace(whitespaceNormalizationRegExp, function (match, _, newline) {
			if (newline) return " ";
			return match;
		});

		// Normalize escape sequences to match browser behavior
		normalized = normalizeSelectorEscapes(normalized);

		// Normalize attribute selectors (add quotes to unquoted values)
		// Returns null if invalid (e.g., unclosed quotes)
		normalized = normalizeAttributeSelectors(normalized);
		if (normalized === null) {
			return ''; // Invalid selector - return empty to trigger validation failure
		}

		// Recursively process pseudo-classes to handle nesting
		return processNestedPseudoClasses(normalized);
	}

	/**
	 * Recursively processes pseudo-classes to filter invalid selectors
	 * 
	 * @param {string} selectorText - The CSS selector text to process
	 * @param {number} depth - Current recursion depth (to prevent infinite loops)
	 * @returns {string} The processed selector text with invalid selectors removed
	 */
	function processNestedPseudoClasses(selectorText, depth) {
		// Prevent infinite recursion
		if (typeof depth === 'undefined') {
			depth = 0;
		}
		if (depth > 10) {
			return selectorText;
		}

		var pseudoClassMatches = extractPseudoClasses(selectorText);

		// If no pseudo-classes found, return as-is
		if (pseudoClassMatches.length === 0) {
			return selectorText;
		}

		// Build result by processing matches from right to left (to preserve positions)
		var result = selectorText;

		for (var j = pseudoClassMatches.length - 1; j >= 0; j--) {
			var pseudoClass = pseudoClassMatches[j][1];
			if (selectorListPseudoClasses.hasOwnProperty(pseudoClass)) {
				var fullMatch = pseudoClassMatches[j][0];
				var pseudoArgs = pseudoClassMatches[j][2];
				var matchStart = pseudoClassMatches[j][3];

				// Check if ANY selector contains & BEFORE processing
				var nestedSelectorsRaw = parseAndSplitNestedSelectors(pseudoArgs);
				var hasAmpersand = false;
				for (var k = 0; k < nestedSelectorsRaw.length; k++) {
					if (ampersandRegExp.test(nestedSelectorsRaw[k])) {
						hasAmpersand = true;
						break;
					}
				}

				// If & is present, skip all processing (keep everything unchanged)
				if (hasAmpersand) {
					continue;
				}

				// Recursively process the arguments
				var processedArgs = processNestedPseudoClasses(pseudoArgs, depth + 1);
				var nestedSelectors = parseAndSplitNestedSelectors(processedArgs);

				// Filter out invalid selectors
				var validSelectors = [];
				for (var i = 0; i < nestedSelectors.length; i++) {
					var nestedSelector = nestedSelectors[i];
					if (basicSelectorValidator(nestedSelector)) {
						validSelectors.push(nestedSelector);
					}
				}

				// Reconstruct the pseudo-class with only valid selectors
				var newArgs = validSelectors.join(', ');
				var newPseudoClass = ':' + pseudoClass + '(' + newArgs + ')';

				// Replace in the result string using position (processing right to left preserves positions)
				result = result.substring(0, matchStart) + newPseudoClass + result.substring(matchStart + fullMatch.length);
			}
		}

		return result;

		return normalized;
	}

	/**
	 * Checks if a selector contains newlines inside quoted strings.
	 * Uses iterative parsing to avoid regex backtracking issues.
	 * @param {string} selectorText - The selector to check
	 * @returns {boolean} True if newlines found inside quotes
	 */
	function hasNewlineInQuotedString(selectorText) {
		for (var i = 0; i < selectorText.length; i++) {
			var char = selectorText[i];
			
			// Start of single-quoted string
			if (char === "'") {
				i++;
				while (i < selectorText.length) {
					if (selectorText[i] === '\\' && i + 1 < selectorText.length) {
						// Skip escape sequence
						i += 2;
						continue;
					}
					if (selectorText[i] === "'") {
						// End of string
						break;
					}
					if (selectorText[i] === '\r' || selectorText[i] === '\n') {
						return true;
					}
					i++;
				}
			}
			// Start of double-quoted string
			else if (char === '"') {
				i++;
				while (i < selectorText.length) {
					if (selectorText[i] === '\\' && i + 1 < selectorText.length) {
						// Skip escape sequence
						i += 2;
						continue;
					}
					if (selectorText[i] === '"') {
						// End of string
						break;
					}
					if (selectorText[i] === '\r' || selectorText[i] === '\n') {
						return true;
					}
					i++;
				}
			}
		}
		return false;
	}

	/**
	 * Checks if a given CSS selector text is valid by splitting it by commas
	 * and validating each individual selector using the `validateSelector` function.
	 *
	 * @param {string} selectorText - The CSS selector text to validate. Can contain multiple selectors separated by commas.
	 * @returns {boolean} Returns true if all selectors are valid, otherwise false.
	 */
	function isValidSelectorText(selectorText) {
		// TODO: The same validations here needs to be reused in CSSStyleRule.selectorText setter
		// TODO: Move these validation logic to a shared function to be reused in CSSStyleRule.selectorText setter

		// Check for empty or whitespace-only selector
		if (!selectorText || selectorText.trim() === '') {
			return false;
		}

		// Check for empty selector lists in pseudo-classes (e.g., :is(), :not(), :where(), :has())
		// These are invalid after filtering out invalid selectors
		if (emptyPseudoClassRegExp.test(selectorText)) {
			return false;
		}

		// Check for newlines inside single or double quotes
		// Uses helper function to avoid regex security issues
		if (hasNewlineInQuotedString(selectorText)) {
			return false;
		}

		// Split selectorText by commas and validate each part
		var selectors = parseAndSplitNestedSelectors(selectorText);
		for (var i = 0; i < selectors.length; i++) {
			var selector = selectors[i].trim();
			if (!validateSelector(selector) || !validateNamespaceSelector(selector)) {
				return false;
			}
		}
		return true;
	}

	function pushToAncestorRules(rule) {
		ancestorRules.push(rule);
	}

	function parseError(message, isNested) {
		var lines = token.substring(0, i).split('\n');
		var lineCount = lines.length;
		var charCount = lines.pop().length + 1;
		var error = new Error(message + ' (line ' + lineCount + ', char ' + charCount + ')');
		error.line = lineCount;
		/* jshint sub : true */
		error['char'] = charCount;
		error.styleSheet = styleSheet;
		error.isNested = !!isNested;
		// Print the error but continue parsing the sheet
		try {
			throw error;
		} catch (e) {
			errorHandler && errorHandler(e);
		}
	};

	/**
	 * Handles invalid selectors with unmatched quotes by skipping the entire rule block.
	 * @param {string} nextState - The parser state to transition to after skipping
	 */
	function handleUnmatchedQuoteInSelector(nextState) {
		// parseError('Invalid selector with unmatched quote: ' + buffer.trim());
		// Skip this entire invalid rule including its block
		var ruleClosingMatch = token.slice(i).match(forwardRuleClosingBraceRegExp);
		if (ruleClosingMatch) {
			i += ruleClosingMatch.index + ruleClosingMatch[0].length - 1;
		}
		styleRule = null;
		buffer = "";
		hasUnmatchedQuoteInSelector = false; // Reset flag
		state = nextState;
	}

	// Helper functions to check character types
	function isSelectorStartChar(char) {
		return '.:#&*['.indexOf(char) !== -1;
	}

	function isWhitespaceChar(char) {
		return ' \t\n\r'.indexOf(char) !== -1;
	}

	// Helper functions for character type checking (faster than regex for single chars)
	function isDigit(char) {
		var code = char.charCodeAt(0);
		return code >= 0x0030 && code <= 0x0039; // 0-9
	}

	function isHexDigit(char) {
		if (!char) return false;
		var code = char.charCodeAt(0);
		return (code >= 0x0030 && code <= 0x0039) || // 0-9
		       (code >= 0x0041 && code <= 0x0046) || // A-F
		       (code >= 0x0061 && code <= 0x0066);   // a-f
	}

	function isLetter(char) {
		if (!char) return false;
		var code = char.charCodeAt(0);
		return (code >= 0x0041 && code <= 0x005A) || // A-Z
		       (code >= 0x0061 && code <= 0x007A);   // a-z
	}

	function isAlphanumeric(char) {
		var code = char.charCodeAt(0);
		return (code >= 0x0030 && code <= 0x0039) || // 0-9
		       (code >= 0x0041 && code <= 0x005A) || // A-Z
		       (code >= 0x0061 && code <= 0x007A);   // a-z
	}

	/**
	 * Get the length of an escape sequence starting at the given position.
	 * CSS escape sequences are:
	 * - Backslash followed by 1-6 hex digits, optionally followed by a whitespace (consumed)
	 * - Backslash followed by any non-hex character
	 * @param {string} str - The string to check
	 * @param {number} pos - Position of the backslash
	 * @returns {number} Number of characters in the escape sequence (including backslash)
	 */
	function getEscapeSequenceLength(str, pos) {
		if (str[pos] !== '\\' || pos + 1 >= str.length) {
			return 0;
		}
		
		var nextChar = str[pos + 1];
		
		// Check if it's a hex escape
		if (isHexDigit(nextChar)) {
			var hexLength = 1;
			// Count up to 6 hex digits
			while (hexLength < 6 && pos + 1 + hexLength < str.length && isHexDigit(str[pos + 1 + hexLength])) {
				hexLength++;
			}
			// Check if followed by optional whitespace (which gets consumed)
			if (pos + 1 + hexLength < str.length && isWhitespaceChar(str[pos + 1 + hexLength])) {
				return 1 + hexLength + 1; // backslash + hex digits + whitespace
			}
			return 1 + hexLength; // backslash + hex digits
		}
		
		// Simple escape: backslash + any character
		return 2;
	}

	/**
	 * Check if a string contains an unescaped occurrence of a specific character
	 * @param {string} str - The string to search
	 * @param {string} char - The character to look for
	 * @returns {boolean} True if the character appears unescaped
	 */
	function containsUnescaped(str, char) {
		for (var i = 0; i < str.length; i++) {
			if (str[i] === '\\') {
				var escapeLen = getEscapeSequenceLength(str, i);
				if (escapeLen > 0) {
					i += escapeLen - 1; // -1 because loop will increment
					continue;
				}
			}
			if (str[i] === char) {
				return true;
			}
		}
		return false;
	}

	var endingIndex = token.length - 1;
	var initialEndingIndex = endingIndex;

	for (var character; (character = token.charAt(i)); i++) {
		if (i === endingIndex) {
			switch (state) {
				case "importRule":
				case "namespaceRule":
				case "layerBlock":
					if (character !== ";") {
						token += ";";
						endingIndex += 1;
					}
					break;
				case "value":
					if (character !== "}") {
						if (character === ";") {
							token += "}"
						} else {
							token += ";";
						}
						endingIndex += 1;
						break;
					}
				case "name":
				case "before-name":
					if (character === "}") {
						token += " "
					} else {
						token += "}"
					}
					endingIndex += 1
					break;
				case "before-selector":
					if (character !== "}" && currentScope !== styleSheet) {
						token += "}"
						endingIndex += 1
						break;
					}
			}
		}

		// Handle escape sequences before processing special characters
		// CSS escape sequences: \HHHHHH (1-6 hex digits) optionally followed by whitespace, or \ + any char
		if (character === '\\' && i + 1 < token.length) {
			var escapeLen = getEscapeSequenceLength(token, i);
			if (escapeLen > 0) {
				buffer += token.substr(i, escapeLen);
				i += escapeLen - 1; // -1 because loop will increment
				continue;
			}
		}

		switch (character) {

			case " ":
			case "\t":
			case "\r":
			case "\n":
			case "\f":
				if (SIGNIFICANT_WHITESPACE[state]) {
					buffer += character;
				}
				break;

			// String
			case '"':
				index = i + 1;
				do {
					index = token.indexOf('"', index) + 1;
					if (!index) {
						parseError('Unmatched "');
						// If we're parsing a selector, flag it as invalid
						if (state === "selector" || state === "atRule") {
							hasUnmatchedQuoteInSelector = true;
						}
					}
				} while (token[index - 2] === '\\');
				if (index === 0) {
					break;
				}
				buffer += token.slice(i, index);
				i = index - 1;
				switch (state) {
					case 'before-value':
						state = 'value';
						break;
					case 'importRule-begin':
						state = 'importRule';
						if (i === endingIndex) {
							token += ';'
						}
						break;
					case 'namespaceRule-begin':
						state = 'namespaceRule';
						if (i === endingIndex) {
							token += ';'
						}
						break;
				}
				break;

			case "'":
				index = i + 1;
				do {
					index = token.indexOf("'", index) + 1;
					if (!index) {
						parseError("Unmatched '");
						// If we're parsing a selector, flag it as invalid
						if (state === "selector" || state === "atRule") {
							hasUnmatchedQuoteInSelector = true;
						}
					}
				} while (token[index - 2] === '\\');
				if (index === 0) {
					break;
				}
				buffer += token.slice(i, index);
				i = index - 1;
				switch (state) {
					case 'before-value':
						state = 'value';
						break;
					case 'importRule-begin':
						state = 'importRule';
						break;
					case 'namespaceRule-begin':
						state = 'namespaceRule';
						break;
				}
				break;

			// Comment
			case "/":
				if (token.charAt(i + 1) === "*") {
					i += 2;
					index = token.indexOf("*/", i);
					if (index === -1) {
						i = token.length - 1;
						buffer = "";
					} else {
						i = index + 1;
					}
				} else {
					buffer += character;
				}
				if (state === "importRule-begin") {
					buffer += " ";
					state = "importRule";
				}
				if (state === "namespaceRule-begin") {
					buffer += " ";
					state = "namespaceRule";
				}
				break;

			// At-rule
			case "@":
				if (nestedSelectorRule) {
					if (styleRule && styleRule.constructor.name === "CSSNestedDeclarations") {
						currentScope.cssRules.push(styleRule);
					}
					// Only reset styleRule to parent if styleRule is not the nestedSelectorRule itself
					// This preserves nested selectors when followed immediately by @-rules
					if (styleRule !== nestedSelectorRule && nestedSelectorRule.parentRule && nestedSelectorRule.parentRule.constructor.name === "CSSStyleRule") {
						styleRule = nestedSelectorRule.parentRule;
					}
					// Don't reset nestedSelectorRule here - preserve it through @-rules
				}
				if (token.indexOf("@-moz-document", i) === i) {
					validateAtRule("@-moz-document", function () {
						state = "documentRule-begin";
						documentRule = new CSSOM.CSSDocumentRule();
						documentRule.__starts = i;
						i += "-moz-document".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@media", i) === i) {
					validateAtRule("@media", function () {
						state = "atBlock";
						mediaRule = new CSSOM.CSSMediaRule();
						mediaRule.__starts = i;
						i += "media".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@container", i) === i) {
					validateAtRule("@container", function () {
						state = "containerBlock";
						containerRule = new CSSOM.CSSContainerRule();
						containerRule.__starts = i;
						i += "container".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@counter-style", i) === i) {
					buffer = "";
					// @counter-style can be nested only inside CSSScopeRule or CSSConditionRule
					// and only if there's no CSSStyleRule in the parent chain
					var cannotBeNested = !canAtRuleBeNested();
					validateAtRule("@counter-style", function () {
						state = "counterStyleBlock"
						counterStyleRule = new CSSOM.CSSCounterStyleRule();
						counterStyleRule.__starts = i;
						i += "counter-style".length;
					}, cannotBeNested);
					break;
				} else if (token.indexOf("@property", i) === i) {
					buffer = "";
					// @property can be nested only inside CSSScopeRule or CSSConditionRule
					// and only if there's no CSSStyleRule in the parent chain
					var cannotBeNested = !canAtRuleBeNested();
					validateAtRule("@property", function () {
						state = "propertyBlock"
						propertyRule = new CSSOM.CSSPropertyRule();
						propertyRule.__starts = i;
						i += "property".length;
					}, cannotBeNested);
					break;
				} else if (token.indexOf("@scope", i) === i) {
					validateAtRule("@scope", function () {
						state = "scopeBlock";
						scopeRule = new CSSOM.CSSScopeRule();
						scopeRule.__starts = i;
						i += "scope".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@layer", i) === i) {
					validateAtRule("@layer", function () {
						state = "layerBlock"
						layerBlockRule = new CSSOM.CSSLayerBlockRule();
						layerBlockRule.__starts = i;
						i += "layer".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@page", i) === i) {
					validateAtRule("@page", function () {
						state = "pageBlock"
						pageRule = new CSSOM.CSSPageRule();
						pageRule.__starts = i;
						i += "page".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@supports", i) === i) {
					validateAtRule("@supports", function () {
						state = "conditionBlock";
						supportsRule = new CSSOM.CSSSupportsRule();
						supportsRule.__starts = i;
						i += "supports".length;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@host", i) === i) {
					validateAtRule("@host", function () {
						state = "hostRule-begin";
						i += "host".length;
						hostRule = new CSSOM.CSSHostRule();
						hostRule.__starts = i;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@starting-style", i) === i) {
					validateAtRule("@starting-style", function () {
						state = "startingStyleRule-begin";
						i += "starting-style".length;
						startingStyleRule = new CSSOM.CSSStartingStyleRule();
						startingStyleRule.__starts = i;
					});
					buffer = "";
					break;
				} else if (token.indexOf("@import", i) === i) {
					buffer = "";
					validateAtRule("@import", function () {
						state = "importRule-begin";
						i += "import".length;
						buffer += "@import";
					}, true);
					break;
				} else if (token.indexOf("@namespace", i) === i) {
					buffer = "";
					validateAtRule("@namespace", function () {
						state = "namespaceRule-begin";
						i += "namespace".length;
						buffer += "@namespace";
					}, true);
					break;
				} else if (token.indexOf("@font-face", i) === i) {
					buffer = "";
					// @font-face can be nested only inside CSSScopeRule or CSSConditionRule
					// and only if there's no CSSStyleRule in the parent chain
					var cannotBeNested = !canAtRuleBeNested();
					validateAtRule("@font-face", function () {
						state = "fontFaceRule-begin";
						i += "font-face".length;
						fontFaceRule = new CSSOM.CSSFontFaceRule();
						fontFaceRule.__starts = i;
					}, cannotBeNested);
					break;
				} else {
					// Reset lastIndex before using global regex (shared instance)
					atKeyframesRegExp.lastIndex = i;
					var matchKeyframes = atKeyframesRegExp.exec(token);
					if (matchKeyframes && matchKeyframes.index === i) {
						state = "keyframesRule-begin";
						keyframesRule = new CSSOM.CSSKeyframesRule();
						keyframesRule.__starts = i;
						keyframesRule._vendorPrefix = matchKeyframes[1]; // Will come out as undefined if no prefix was found
						i += matchKeyframes[0].length - 1;
						buffer = "";
						break;
					} else if (state === "selector") {
						state = "atRule";
					}
				}
				buffer += character;
				break;

			case "{":
				if (currentScope === topScope) {
					nestedSelectorRule = null;
				}
				if (state === 'before-selector') {
					parseError("Unexpected {");
					i = ignoreBalancedBlock(i, token.slice(i));
					break;
				}
				if (state === "selector" || state === "atRule") {
					if (!nestedSelectorRule && containsUnescaped(buffer, ";")) {
						var ruleClosingMatch = token.slice(i).match(forwardRuleClosingBraceRegExp);
						if (ruleClosingMatch) {
							styleRule = null;
							buffer = "";
							state = "before-selector";
							i += ruleClosingMatch.index + ruleClosingMatch[0].length;
							break;
						}
					}

					// Ensure styleRule exists before trying to set properties on it
					if (!styleRule) {
						styleRule = new CSSOM.CSSStyleRule();
						styleRule.__starts = i;
					}

					// Check if tokenizer detected an unmatched quote BEFORE setting up the rule
					if (hasUnmatchedQuoteInSelector) {
						handleUnmatchedQuoteInSelector("before-selector");
						break;
					}

					var originalParentRule = parentRule;

					if (parentRule) {
						styleRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
					}

					currentScope = parentRule = styleRule;
					
					var processedSelectorText = processSelectorText(buffer.trim());
					// In a nested selector, ensure each selector contains '&' at the beginning, except for selectors that already have '&' somewhere
					if (originalParentRule && originalParentRule.constructor.name === "CSSStyleRule") {
						styleRule.selectorText = parseAndSplitNestedSelectors(processedSelectorText).map(function (sel) {
							// Add & at the beginning if there's no & in the selector, or if it starts with a combinator
							return (sel.indexOf('&') === -1 || startsWithCombinatorRegExp.test(sel)) ? '& ' + sel : sel;
						}).join(', ');
					} else {
						// Normalize comma spacing: split by commas and rejoin with ", "
						styleRule.selectorText = parseAndSplitNestedSelectors(processedSelectorText).join(', ');
					}
					styleRule.style.__starts = i;
					styleRule.__parentStyleSheet = styleSheet;
					buffer = "";
					state = "before-name";
				} else if (state === "atBlock") {
					mediaRule.media.mediaText = buffer.trim();

					if (parentRule) {
						mediaRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
						// If entering @media from within a CSSStyleRule, set nestedSelectorRule
						// so that & selectors and declarations work correctly inside
						if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
							nestedSelectorRule = parentRule;
						}
					}

					currentScope = parentRule = mediaRule;
					pushToAncestorRules(mediaRule);
					mediaRule.__parentStyleSheet = styleSheet;
					
					// Don't reset styleRule to null if it's a nested CSSStyleRule that will contain this @-rule
					if (!styleRule || styleRule.constructor.name !== "CSSStyleRule" || !styleRule.__parentRule) {
						styleRule = null; // Reset styleRule when entering @-rule
					}
					
					buffer = "";
					state = "before-selector";
				} else if (state === "containerBlock") {
					containerRule.__conditionText = buffer.trim();

					if (parentRule) {
						containerRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
						if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
							nestedSelectorRule = parentRule;
						}
					}
					currentScope = parentRule = containerRule;
					pushToAncestorRules(containerRule);
					containerRule.__parentStyleSheet = styleSheet;
					styleRule = null; // Reset styleRule when entering @-rule
					buffer = "";
					state = "before-selector";
				} else if (state === "counterStyleBlock") {
					var counterStyleName = buffer.trim().replace(newlineRemovalRegExp, "");
					// Validate: name cannot be empty, contain whitespace, or contain dots
					var isValidCounterStyleName = counterStyleName.length > 0 && !whitespaceAndDotRegExp.test(counterStyleName);

					if (isValidCounterStyleName) {
						counterStyleRule.name = counterStyleName;
						if (parentRule) {
							counterStyleRule.__parentRule = parentRule;
						}
						counterStyleRule.__parentStyleSheet = styleSheet;
						styleRule = counterStyleRule;
					}
					buffer = "";
				} else if (state === "propertyBlock") {
					var propertyName = buffer.trim().replace(newlineRemovalRegExp, "");
					// Validate: name must start with -- (custom property)
					var isValidPropertyName = propertyName.indexOf("--") === 0;

					if (isValidPropertyName) {
						propertyRule.__name = propertyName;
						if (parentRule) {
							propertyRule.__parentRule = parentRule;
						}
						propertyRule.__parentStyleSheet = styleSheet;
						styleRule = propertyRule;
					}
					buffer = "";
				} else if (state === "conditionBlock") {
					supportsRule.__conditionText = buffer.trim();

					if (parentRule) {
						supportsRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
						if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
							nestedSelectorRule = parentRule;
						}
					}

					currentScope = parentRule = supportsRule;
					pushToAncestorRules(supportsRule);
					supportsRule.__parentStyleSheet = styleSheet;
					styleRule = null; // Reset styleRule when entering @-rule
					buffer = "";
					state = "before-selector";
				} else if (state === "scopeBlock") {
					var parsedScopePrelude = parseScopePrelude(buffer.trim());

					if (parsedScopePrelude.hasStart) {
						scopeRule.__start = parsedScopePrelude.startSelector;
					}
					if (parsedScopePrelude.hasEnd) {
						scopeRule.__end = parsedScopePrelude.endSelector;
					}
					if (parsedScopePrelude.hasOnlyEnd) {
						scopeRule.__end = parsedScopePrelude.endSelector;
					}

					if (parentRule) {
						scopeRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
						if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
							nestedSelectorRule = parentRule;
						}
					}
					currentScope = parentRule = scopeRule;
					pushToAncestorRules(scopeRule);
					scopeRule.__parentStyleSheet = styleSheet;
					styleRule = null; // Reset styleRule when entering @-rule
					buffer = "";
					state = "before-selector";
				} else if (state === "layerBlock") {
					layerBlockRule.name = buffer.trim();

					var isValidName = layerBlockRule.name.length === 0 || layerBlockRule.name.match(cssCustomIdentifierRegExp) !== null;

					if (isValidName) {
						if (parentRule) {
							layerBlockRule.__parentRule = parentRule;
							pushToAncestorRules(parentRule);
							if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
								nestedSelectorRule = parentRule;
							}
						}

						currentScope = parentRule = layerBlockRule;
						pushToAncestorRules(layerBlockRule);
						layerBlockRule.__parentStyleSheet = styleSheet;
					}
					styleRule = null; // Reset styleRule when entering @-rule
					buffer = "";
					state = "before-selector";
				} else if (state === "pageBlock") {
					pageRule.selectorText = buffer.trim();

					if (parentRule) {
						pageRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
					}

					currentScope = parentRule = pageRule;
					pageRule.__parentStyleSheet = styleSheet;
					styleRule = pageRule;
					buffer = "";
					state = "before-name";
				} else if (state === "hostRule-begin") {
					if (parentRule) {
						pushToAncestorRules(parentRule);
					}

					currentScope = parentRule = hostRule;
					pushToAncestorRules(hostRule);
					hostRule.__parentStyleSheet = styleSheet;
					buffer = "";
					state = "before-selector";
				} else if (state === "startingStyleRule-begin") {
					if (parentRule) {
						startingStyleRule.__parentRule = parentRule;
						pushToAncestorRules(parentRule);
						if (parentRule.constructor.name === "CSSStyleRule" && !nestedSelectorRule) {
							nestedSelectorRule = parentRule;
						}
					}

					currentScope = parentRule = startingStyleRule;
					pushToAncestorRules(startingStyleRule);
					startingStyleRule.__parentStyleSheet = styleSheet;
					styleRule = null; // Reset styleRule when entering @-rule
					buffer = "";
					state = "before-selector";

				} else if (state === "fontFaceRule-begin") {
					if (parentRule) {
						fontFaceRule.__parentRule = parentRule;
					}
					fontFaceRule.__parentStyleSheet = styleSheet;
					styleRule = fontFaceRule;
					buffer = "";
					state = "before-name";
				} else if (state === "keyframesRule-begin") {
					keyframesRule.name = buffer.trim();
					if (parentRule) {
						pushToAncestorRules(parentRule);
						keyframesRule.__parentRule = parentRule;
					}
					keyframesRule.__parentStyleSheet = styleSheet;
					currentScope = parentRule = keyframesRule;
					buffer = "";
					state = "keyframeRule-begin";
				} else if (state === "keyframeRule-begin") {
					styleRule = new CSSOM.CSSKeyframeRule();
					styleRule.keyText = buffer.trim();
					styleRule.__starts = i;
					buffer = "";
					state = "before-name";
				} else if (state === "documentRule-begin") {
					// FIXME: what if this '{' is in the url text of the match function?
					documentRule.matcher.matcherText = buffer.trim();
					if (parentRule) {
						pushToAncestorRules(parentRule);
						documentRule.__parentRule = parentRule;
					}
					currentScope = parentRule = documentRule;
					pushToAncestorRules(documentRule);
					documentRule.__parentStyleSheet = styleSheet;
					buffer = "";
					state = "before-selector";
				} else if (state === "before-name" || state === "name") {
					// @font-face and similar rules don't support nested selectors
					// If we encounter a nested selector block inside them, skip it
					if (styleRule.constructor.name === "CSSFontFaceRule" ||
						styleRule.constructor.name === "CSSKeyframeRule" ||
						(styleRule.constructor.name === "CSSPageRule" && parentRule === styleRule)) {
						// Skip the nested block
						var ruleClosingMatch = token.slice(i).match(forwardRuleClosingBraceRegExp);
						if (ruleClosingMatch) {
							i += ruleClosingMatch.index + ruleClosingMatch[0].length - 1;
							buffer = "";
							state = "before-name";
							break;
						}
					}

					if (styleRule.constructor.name === "CSSNestedDeclarations") {
						if (styleRule.style.length) {
							parentRule.cssRules.push(styleRule);
							styleRule.__parentRule = parentRule;
							styleRule.__parentStyleSheet = styleSheet;
							pushToAncestorRules(parentRule);
						} else {
							// If the styleRule is empty, we can assume that it's a nested selector
							pushToAncestorRules(parentRule);
						}
					} else {
						currentScope = parentRule = styleRule;
						pushToAncestorRules(parentRule);
						styleRule.__parentStyleSheet = styleSheet;
					}

					styleRule = new CSSOM.CSSStyleRule();
					
					// Check if tokenizer detected an unmatched quote BEFORE setting up the rule
					if (hasUnmatchedQuoteInSelector) {
						handleUnmatchedQuoteInSelector("before-name");
						break;
					}
					
					var processedSelectorText = processSelectorText(buffer.trim());
					// In a nested selector, ensure each selector contains '&' at the beginning, except for selectors that already have '&' somewhere
					if (parentRule.constructor.name === "CSSScopeRule" || (parentRule.constructor.name !== "CSSStyleRule" && parentRule.parentRule === null)) {
						// Normalize comma spacing: split by commas and rejoin with ", "
						styleRule.selectorText = parseAndSplitNestedSelectors(processedSelectorText).join(', ');
					} else {
						styleRule.selectorText = parseAndSplitNestedSelectors(processedSelectorText).map(function (sel) {
							// Add & at the beginning if there's no & in the selector, or if it starts with a combinator
							return (sel.indexOf('&') === -1 || startsWithCombinatorRegExp.test(sel)) ? '& ' + sel : sel;
						}).join(', ');
					}
					styleRule.style.__starts = i - buffer.length;
					styleRule.__parentRule = parentRule;
					// Only set nestedSelectorRule if we're directly inside a CSSStyleRule or CSSScopeRule,
					// not inside other grouping rules like @media/@supports
					if (parentRule.constructor.name === "CSSStyleRule" || parentRule.constructor.name === "CSSScopeRule") {
						nestedSelectorRule = styleRule;
					}
					
					// Set __parentStyleSheet for the new nested styleRule
					styleRule.__parentStyleSheet = styleSheet;
					
					// Update currentScope and parentRule to the new nested styleRule
					// so that subsequent content (like @-rules) will be children of this rule
					currentScope = parentRule = styleRule;

					buffer = "";
					state = "before-name";
				}
				break;

			case ":":
				if (state === "name") {
					// It can be a nested selector, let's check
					var openBraceBeforeMatch = token.slice(i).match(declarationOrOpenBraceRegExp);
					var hasOpenBraceBefore = openBraceBeforeMatch && openBraceBeforeMatch[0] === '{';
					if (hasOpenBraceBefore) {
						// Is a selector
						buffer += character;
					} else {
						// Is a declaration
						name = buffer.trim();
						buffer = "";
						state = "before-value";
					}
				} else {
					buffer += character;
				}
				break;

			case "(":
				if (state === 'value') {
					// ie css expression mode
					if (buffer.trim() === 'expression') {
						var info = (new CSSOM.CSSValueExpression(token, i)).parse();

						if (info.error) {
							parseError(info.error);
						} else {
							buffer += info.expression;
							i = info.idx;
						}
					} else {
						state = 'value-parenthesis';
						//always ensure this is reset to 1 on transition
						//from value to value-parenthesis
						valueParenthesisDepth = 1;
						buffer += character;
					}
				} else if (state === 'value-parenthesis') {
					valueParenthesisDepth++;
					buffer += character;
				} else {
					buffer += character;
				}
				break;

			case ")":
				if (state === 'value-parenthesis') {
					valueParenthesisDepth--;
					if (valueParenthesisDepth === 0) state = 'value';
				}
				buffer += character;
				break;

			case "!":
				if (state === "value" && token.indexOf("!important", i) === i) {
					priority = "important";
					i += "important".length;
				} else {
					buffer += character;
				}
				break;

			case ";":
				switch (state) {
					case "before-value":
					case "before-name":
						parseError("Unexpected ;");
						buffer = "";
						state = "before-name";
						break;
					case "value":
						styleRule.style.setProperty(name, buffer.trim(), priority, parseError);
						priority = "";
						buffer = "";
						state = "before-name";
						break;
					case "atRule":
						buffer = "";
						state = "before-selector";
						break;
					case "importRule":
						var isValid = topScope.cssRules.length === 0 || topScope.cssRules.some(function (rule) {
							return ['CSSImportRule', 'CSSLayerStatementRule'].indexOf(rule.constructor.name) !== -1
						});
						if (isValid) {
							importRule = new CSSOM.CSSImportRule();
							if (opts && opts.globalObject && opts.globalObject.CSSStyleSheet) {
								importRule.__styleSheet = new opts.globalObject.CSSStyleSheet();
							}
							importRule.styleSheet.__constructed = false;
							importRule.__parentStyleSheet = importRule.styleSheet.__parentStyleSheet = styleSheet;
							importRule.parse(buffer + character);
							topScope.cssRules.push(importRule);
						}
						buffer = "";
						state = "before-selector";
						break;
					case "namespaceRule":
						var isValid = topScope.cssRules.length === 0 || topScope.cssRules.every(function (rule) {
							return ['CSSImportRule', 'CSSLayerStatementRule', 'CSSNamespaceRule'].indexOf(rule.constructor.name) !== -1
						});
						if (isValid) {
							try {
								// Validate namespace syntax before creating the rule
								var testNamespaceRule = new CSSOM.CSSNamespaceRule();
								testNamespaceRule.parse(buffer + character);

								namespaceRule = testNamespaceRule;
								namespaceRule.__parentStyleSheet = styleSheet;
								topScope.cssRules.push(namespaceRule);

								// Track the namespace prefix for validation
								if (namespaceRule.prefix) {
									definedNamespacePrefixes[namespaceRule.prefix] = namespaceRule.namespaceURI;
								}
							} catch (e) {
								parseError(e.message);
							}
						}
						buffer = "";
						state = "before-selector";
						break;
					case "layerBlock":
						var nameListStr = buffer.trim().split(",").map(function (name) {
							return name.trim();
						});
						var isInvalid = nameListStr.some(function (name) {
							return name.trim().match(cssCustomIdentifierRegExp) === null;
						});

						// Check if there's a CSSStyleRule in the parent chain
						var hasStyleRuleParent = false;
						if (parentRule) {
							var checkParent = parentRule;
							while (checkParent) {
								if (checkParent.constructor.name === "CSSStyleRule") {
									hasStyleRuleParent = true;
									break;
								}
								checkParent = checkParent.__parentRule;
							}
						}

						if (!isInvalid && !hasStyleRuleParent) {
							layerStatementRule = new CSSOM.CSSLayerStatementRule();
							layerStatementRule.__parentStyleSheet = styleSheet;
							layerStatementRule.__starts = layerBlockRule.__starts;
							layerStatementRule.__ends = i;
							layerStatementRule.nameList = nameListStr;

							// Add to parent rule if nested, otherwise to top scope
							if (parentRule) {
								layerStatementRule.__parentRule = parentRule;
								parentRule.cssRules.push(layerStatementRule);
							} else {
								topScope.cssRules.push(layerStatementRule);
							}
						}
						buffer = "";
						state = "before-selector";
						break;
					default:
						buffer += character;
						break;
				}
				break;

			case "}":
				if (state === "counterStyleBlock") {
					// FIXME : Implement missing properties on CSSCounterStyleRule interface and update parse method
					// For now it's just assigning entire rule text
					if (counterStyleRule.name) {
						// Only process if name was set (valid)
						counterStyleRule.parse("@counter-style " + counterStyleRule.name + " { " + buffer + " }");
						counterStyleRule.__ends = i + 1;
						// Add to parent's cssRules
						if (counterStyleRule.__parentRule) {
							counterStyleRule.__parentRule.cssRules.push(counterStyleRule);
						} else {
							topScope.cssRules.push(counterStyleRule);
						}
					}
					// Restore currentScope to parent after closing this rule
					if (counterStyleRule.__parentRule) {
						currentScope = counterStyleRule.__parentRule;
					}
					styleRule = null;
					buffer = "";
					state = "before-selector";
					break;
				}
				if (state === "propertyBlock") {
					// Only process if name was set (valid)
					if (propertyRule.__name) {
						var parseSuccess = propertyRule.parse("@property " + propertyRule.__name + " { " + buffer + " }");
						// Only add the rule if parse was successful (syntax, inherits, and initial-value validation passed)
						if (parseSuccess) {
							propertyRule.__ends = i + 1;
							// Add to parent's cssRules
							if (propertyRule.__parentRule) {
								propertyRule.__parentRule.cssRules.push(propertyRule);
							} else {
								topScope.cssRules.push(propertyRule);
							}
						}
					}
					// Restore currentScope to parent after closing this rule
					if (propertyRule.__parentRule) {
						currentScope = propertyRule.__parentRule;
					}
					styleRule = null;
					buffer = "";
					state = "before-selector";
					break;
				}
				switch (state) {
					case "value":
						styleRule.style.setProperty(name, buffer.trim(), priority, parseError);
						priority = "";
					/* falls through */
					case "before-value":
					case "before-name":
					case "name":
						styleRule.__ends = i + 1;

						if (parentRule === styleRule) {
							parentRule = ancestorRules.pop()
						}

						if (parentRule) {
							styleRule.__parentRule = parentRule;
						}
						styleRule.__parentStyleSheet = styleSheet;

						if (currentScope === styleRule) {
							currentScope = parentRule || topScope;
						}

						if (styleRule.constructor.name === "CSSStyleRule" && !isValidSelectorText(styleRule.selectorText)) {
							if (styleRule === nestedSelectorRule) {
								nestedSelectorRule = null;
							}
							parseError('Invalid CSSStyleRule (selectorText = "' + styleRule.selectorText + '")', styleRule.parentRule !== null);
						} else {
							if (styleRule.parentRule) {
								styleRule.parentRule.cssRules.push(styleRule);
							} else {
								currentScope.cssRules.push(styleRule);
							}
						}
						buffer = "";
						if (currentScope.constructor === CSSOM.CSSKeyframesRule) {
							state = "keyframeRule-begin";
						} else {
							state = "before-selector";
						}

						if (styleRule.constructor.name === "CSSNestedDeclarations") {
							if (currentScope !== topScope) {
								// Only set nestedSelectorRule if currentScope is CSSStyleRule or CSSScopeRule
								// Not for other grouping rules like @media/@supports
								if (currentScope.constructor.name === "CSSStyleRule" || currentScope.constructor.name === "CSSScopeRule") {
									nestedSelectorRule = currentScope;
								}
							}
							styleRule = null;
						} else {
							// Update nestedSelectorRule when closing a CSSStyleRule
							if (styleRule === nestedSelectorRule) {
								var selector = styleRule.selectorText && styleRule.selectorText.trim();
								// Check if this is proper nesting (&.class, &:pseudo) vs prepended & (& :is, & .class with space)
								// Prepended & has pattern "& X" where X starts with : or .
								var isPrependedAmpersand = selector && selector.match(prependedAmpersandRegExp);

								// Check if parent is a grouping rule that can contain nested selectors
								var isGroupingRule = currentScope && currentScope instanceof CSSOM.CSSGroupingRule;

								if (!isPrependedAmpersand && isGroupingRule) {
									// Proper nesting - set nestedSelectorRule to parent for more nested selectors
									// But only if it's a CSSStyleRule or CSSScopeRule, not other grouping rules like @media
									if (currentScope.constructor.name === "CSSStyleRule" || currentScope.constructor.name === "CSSScopeRule") {
										nestedSelectorRule = currentScope;
									}
									// If currentScope is another type of grouping rule (like @media), keep nestedSelectorRule unchanged
								} else {
									// Prepended & or not nested in grouping rule - reset to prevent CSSNestedDeclarations
									nestedSelectorRule = null;
								}
							} else if (nestedSelectorRule && currentScope instanceof CSSOM.CSSGroupingRule) {
								// When closing a nested rule that's not the nestedSelectorRule itself,
								// maintain nestedSelectorRule if we're still inside a grouping rule
								// This ensures declarations after nested selectors inside @media/@supports etc. work correctly
							}
							styleRule = null;
							break;
						}
					case "keyframeRule-begin":
					case "before-selector":
					case "selector":
						// End of media/supports/document rule.
						if (!parentRule) {
							parseError("Unexpected }");

							var hasPreviousStyleRule = currentScope.cssRules.length && currentScope.cssRules[currentScope.cssRules.length - 1].constructor.name === "CSSStyleRule";
							if (hasPreviousStyleRule) {
								i = ignoreBalancedBlock(i, token.slice(i), 1);
							}

							break;
						}

						// Find the actual parent rule by popping from ancestor stack
						while (ancestorRules.length > 0) {
							parentRule = ancestorRules.pop();

							// Skip if we popped the current scope itself (happens because we push both rule and parent)
							if (parentRule === currentScope) {
								continue;
							}

							// Only process valid grouping rules
							if (!(parentRule instanceof CSSOM.CSSGroupingRule && (parentRule.constructor.name !== 'CSSStyleRule' || parentRule.__parentRule))) {
								continue;
							}

							// Determine if we're closing a special nested selector context
							var isClosingNestedSelectorContext = nestedSelectorRule && 
								(currentScope === nestedSelectorRule || nestedSelectorRule.__parentRule === currentScope);

							if (isClosingNestedSelectorContext) {
								// Closing the nestedSelectorRule or its direct container
								if (nestedSelectorRule.parentRule) {
									// Add nestedSelectorRule to its parent and update scope
									prevScope = nestedSelectorRule;
									currentScope = nestedSelectorRule.parentRule;
									// Use object lookup instead of O(n) indexOf
									var scopeId = getRuleId(prevScope);
									if (!addedToCurrentScope[scopeId]) {
										currentScope.cssRules.push(prevScope);
										addedToCurrentScope[scopeId] = true;
									}
									nestedSelectorRule = currentScope;
									// Stop here to preserve context for sibling selectors
									break;
								} else {
									// Top-level CSSStyleRule with nested grouping rule
									prevScope = currentScope;
									var actualParent = ancestorRules.length > 0 ? ancestorRules[ancestorRules.length - 1] : nestedSelectorRule;
									if (actualParent !== prevScope) {
										actualParent.cssRules.push(prevScope);
									}
									currentScope = actualParent;
									parentRule = actualParent;
									break;
								}
							} else {
								// Regular case: add currentScope to parentRule
								prevScope = currentScope;
								if (parentRule !== prevScope) {
									parentRule.cssRules.push(prevScope);
								}
								break;
							}
						}

						// If currentScope has a __parentRule and wasn't added yet, add it
						if (ancestorRules.length === 0 && currentScope.__parentRule && currentScope.__parentRule.cssRules) {
							// Use object lookup instead of O(n) findIndex
							var parentId = getRuleId(currentScope);
							if (!addedToParent[parentId]) {
								currentScope.__parentRule.cssRules.push(currentScope);
								addedToParent[parentId] = true;
							}
						}

						// Only handle top-level rule closing if we processed all ancestors
						if (ancestorRules.length === 0 && currentScope.parentRule == null) {
							currentScope.__ends = i + 1;
							// Use object lookup instead of O(n) findIndex
							var topId = getRuleId(currentScope);
							if (currentScope !== topScope && !addedToTopScope[topId]) {
								topScope.cssRules.push(currentScope);
								addedToTopScope[topId] = true;
							}
							currentScope = topScope;
							if (nestedSelectorRule === parentRule) {
								// Check if this selector is really starting inside another selector
								var nestedSelectorTokenToCurrentSelectorToken = token.slice(nestedSelectorRule.__starts, i + 1);
								var openingBraceMatch = nestedSelectorTokenToCurrentSelectorToken.match(openBraceGlobalRegExp);
								var closingBraceMatch = nestedSelectorTokenToCurrentSelectorToken.match(closeBraceGlobalRegExp);
								var openingBraceLen = openingBraceMatch && openingBraceMatch.length;
								var closingBraceLen = closingBraceMatch && closingBraceMatch.length;

								if (openingBraceLen === closingBraceLen) {
									// If the number of opening and closing braces are equal, we can assume that the new selector is starting outside the nestedSelectorRule
									nestedSelectorRule.__ends = i + 1;
									nestedSelectorRule = null;
									parentRule = null;
								}
							} else {
								parentRule = null;
							}
						} else {
							currentScope = parentRule;
						}

						buffer = "";
						state = "before-selector";
						break;
				}
				break;

			default:
				switch (state) {
					case "before-selector":
						state = "selector";
						if ((styleRule || scopeRule) && parentRule) {
							// Assuming it's a declaration inside Nested Selector OR a Nested Declaration
							// If Declaration inside Nested Selector let's keep the same styleRule
							if (!isSelectorStartChar(character) && !isWhitespaceChar(character) && parentRule instanceof CSSOM.CSSGroupingRule) {
								// parentRule.__parentRule = styleRule;
								state = "before-name";
								if (styleRule !== parentRule) {
									styleRule = new CSSOM.CSSNestedDeclarations();
									styleRule.__starts = i;
								}
							}

						} else if (nestedSelectorRule && parentRule && parentRule instanceof CSSOM.CSSGroupingRule) {
							if (isSelectorStartChar(character)) {
								// If starting with a selector character, create CSSStyleRule instead of CSSNestedDeclarations
								styleRule = new CSSOM.CSSStyleRule();
								styleRule.__starts = i;
							} else if (!isWhitespaceChar(character)) {
								// Starting a declaration (not whitespace, not a selector)
								state = "before-name";
								// Check if we should create CSSNestedDeclarations
								// This happens if: parent has cssRules OR nestedSelectorRule exists (indicating CSSStyleRule in hierarchy)
								if (parentRule.cssRules.length || nestedSelectorRule) {
									currentScope = parentRule;
									// Only set nestedSelectorRule if parentRule is CSSStyleRule or CSSScopeRule
									if (parentRule.constructor.name === "CSSStyleRule" || parentRule.constructor.name === "CSSScopeRule") {
										nestedSelectorRule = parentRule;
									}
									styleRule = new CSSOM.CSSNestedDeclarations();
									styleRule.__starts = i;
								} else {
									if (parentRule.constructor.name === "CSSStyleRule") {
										styleRule = parentRule;
									} else {
										styleRule = new CSSOM.CSSStyleRule();
										styleRule.__starts = i;
									}
								}
							}
						}
						break;
					case "before-name":
						state = "name";
						break;
					case "before-value":
						state = "value";
						break;
					case "importRule-begin":
						state = "importRule";
						break;
					case "namespaceRule-begin":
						state = "namespaceRule";
						break;
				}
				buffer += character;
				break;
		}

		// Auto-close all unclosed nested structures
		// Check AFTER processing the character, at the ORIGINAL ending index
		// Only add closing braces if CSS is incomplete (not at top scope)
		if (i === initialEndingIndex && (currentScope !== topScope || ancestorRules.length > 0)) {
			var needsClosing = ancestorRules.length;
			if (currentScope !== topScope && ancestorRules.indexOf(currentScope) === -1) {
				needsClosing += 1;
			}
			// Add closing braces for all unclosed structures
			for (var closeIdx = 0; closeIdx < needsClosing; closeIdx++) {
				token += "}";
				endingIndex += 1;
			}
		}
	}

	if (buffer.trim() !== "") {
		parseError("Unexpected end of input");
	}

	return styleSheet;
};






/**
 * Produces a deep copy of stylesheet — the instance variables of stylesheet are copied recursively.
 * @param {CSSStyleSheet|CSSOM.CSSStyleSheet} stylesheet
 * @nosideeffects
 * @return {CSSOM.CSSStyleSheet}
 */
CSSOM.clone = function clone(stylesheet) {

	var cloned = new CSSOM.CSSStyleSheet();

	var rules = stylesheet.cssRules;
	if (!rules) {
		return cloned;
	}

	for (var i = 0, rulesLength = rules.length; i < rulesLength; i++) {
		var rule = rules[i];
		var ruleClone = cloned.cssRules[i] = new rule.constructor();

		var style = rule.style;
		if (style) {
			var styleClone = ruleClone.style = new CSSOM.CSSStyleDeclaration();
			for (var j = 0, styleLength = style.length; j < styleLength; j++) {
				var name = styleClone[j] = style[j];
				styleClone[name] = style[name];
				styleClone._importants[name] = style.getPropertyPriority(name);
			}
			styleClone.length = style.length;
		}

		if (rule.hasOwnProperty('keyText')) {
			ruleClone.keyText = rule.keyText;
		}

		if (rule.hasOwnProperty('selectorText')) {
			ruleClone.selectorText = rule.selectorText;
		}

		if (rule.hasOwnProperty('mediaText')) {
			ruleClone.mediaText = rule.mediaText;
		}

		if (rule.hasOwnProperty('supportsText')) {
			ruleClone.supports = rule.supports;
		}

		if (rule.hasOwnProperty('conditionText')) {
			ruleClone.conditionText = rule.conditionText;
		}

		if (rule.hasOwnProperty('layerName')) {
			ruleClone.layerName = rule.layerName;
		}

		if (rule.hasOwnProperty('href')) {
			ruleClone.href = rule.href;
		}

		if (rule.hasOwnProperty('name')) {
			ruleClone.name = rule.name;
		}

		if (rule.hasOwnProperty('nameList')) {
			ruleClone.nameList = rule.nameList;
		}

		if (rule.hasOwnProperty('cssRules')) {
			ruleClone.cssRules = clone(rule).cssRules;
		}
	}

	return cloned;

};


