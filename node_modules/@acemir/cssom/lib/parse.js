//.CommonJS
var CSSOM = {};
var regexPatterns = require("./regexPatterns").regexPatterns;
///CommonJS

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


//.CommonJS
exports.parse = CSSOM.parse;
// The following modules cannot be included sooner due to the mutual dependency with parse.js
CSSOM.CSSStyleSheet = require("./CSSStyleSheet").CSSStyleSheet;
CSSOM.CSSStyleRule = require("./CSSStyleRule").CSSStyleRule;
CSSOM.CSSNestedDeclarations = require("./CSSNestedDeclarations").CSSNestedDeclarations;
CSSOM.CSSImportRule = require("./CSSImportRule").CSSImportRule;
CSSOM.CSSNamespaceRule = require("./CSSNamespaceRule").CSSNamespaceRule;
CSSOM.CSSGroupingRule = require("./CSSGroupingRule").CSSGroupingRule;
CSSOM.CSSMediaRule = require("./CSSMediaRule").CSSMediaRule;
CSSOM.CSSCounterStyleRule = require("./CSSCounterStyleRule").CSSCounterStyleRule;
CSSOM.CSSPropertyRule = require("./CSSPropertyRule").CSSPropertyRule;
CSSOM.CSSContainerRule = require("./CSSContainerRule").CSSContainerRule;
CSSOM.CSSConditionRule = require("./CSSConditionRule").CSSConditionRule;
CSSOM.CSSSupportsRule = require("./CSSSupportsRule").CSSSupportsRule;
CSSOM.CSSFontFaceRule = require("./CSSFontFaceRule").CSSFontFaceRule;
CSSOM.CSSHostRule = require("./CSSHostRule").CSSHostRule;
CSSOM.CSSStartingStyleRule = require("./CSSStartingStyleRule").CSSStartingStyleRule;
CSSOM.CSSStyleDeclaration = require('./CSSStyleDeclaration').CSSStyleDeclaration;
CSSOM.CSSKeyframeRule = require('./CSSKeyframeRule').CSSKeyframeRule;
CSSOM.CSSKeyframesRule = require('./CSSKeyframesRule').CSSKeyframesRule;
CSSOM.CSSValueExpression = require('./CSSValueExpression').CSSValueExpression;
CSSOM.CSSDocumentRule = require('./CSSDocumentRule').CSSDocumentRule;
CSSOM.CSSScopeRule = require('./CSSScopeRule').CSSScopeRule;
CSSOM.CSSLayerBlockRule = require("./CSSLayerBlockRule").CSSLayerBlockRule;
CSSOM.CSSLayerStatementRule = require("./CSSLayerStatementRule").CSSLayerStatementRule;
CSSOM.CSSPageRule = require("./CSSPageRule").CSSPageRule;
// Use cssstyle if available
require("./cssstyleTryCatchBlock");
///CommonJS
