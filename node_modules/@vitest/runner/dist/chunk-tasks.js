import { processError } from '@vitest/utils/error';
import { parseSingleStack } from '@vitest/utils/source-map';
import { relative } from 'pathe';
import { toArray } from '@vitest/utils/helpers';

const kChainableContext = Symbol("kChainableContext");
function getChainableContext(chainable) {
	return chainable?.[kChainableContext];
}
function createChainable(keys, fn, context) {
	function create(context) {
		const chain = function(...args) {
			return fn.apply(context, args);
		};
		Object.assign(chain, fn);
		Object.defineProperty(chain, kChainableContext, {
			value: {
				withContext: () => chain.bind(context),
				getFixtures: () => context.fixtures,
				setContext: (key, value) => {
					context[key] = value;
				},
				mergeContext: (ctx) => {
					Object.assign(context, ctx);
				}
			},
			enumerable: false
		});
		for (const key of keys) {
			Object.defineProperty(chain, key, { get() {
				return create({
					...context,
					[key]: true
				});
			} });
		}
		return chain;
	}
	const chain = create(context ?? {});
	Object.defineProperty(chain, "fn", {
		value: fn,
		enumerable: false
	});
	return chain;
}

/**
* If any tasks been marked as `only`, mark all other tasks as `skip`.
*/
function interpretTaskModes(file, namePattern, testLocations, testIds, testTagsFilter, onlyMode, parentIsOnly, allowOnly) {
	const matchedLocations = [];
	const traverseSuite = (suite, parentIsOnly, parentMatchedWithLocation) => {
		const suiteIsOnly = parentIsOnly || suite.mode === "only";
		// Check if any tasks in this suite have `.only` - if so, only those should run
		const hasSomeTasksOnly = onlyMode && suite.tasks.some((t) => t.mode === "only" || t.type === "suite" && someTasksAreOnly(t));
		suite.tasks.forEach((t) => {
			// Check if either the parent suite or the task itself are marked as included
			// If there are tasks with `.only` in this suite, only include those (not all tasks from describe.only)
			const includeTask = hasSomeTasksOnly ? t.mode === "only" || t.type === "suite" && someTasksAreOnly(t) : suiteIsOnly || t.mode === "only";
			if (onlyMode) {
				if (t.type === "suite" && (includeTask || someTasksAreOnly(t))) {
					// Don't skip this suite
					if (t.mode === "only") {
						checkAllowOnly(t, allowOnly);
						t.mode = "run";
					}
				} else if (t.mode === "run" && !includeTask) {
					t.mode = "skip";
				} else if (t.mode === "only") {
					checkAllowOnly(t, allowOnly);
					t.mode = "run";
				}
			}
			let hasLocationMatch = parentMatchedWithLocation;
			// Match test location against provided locations, only run if present
			// in `testLocations`. Note: if `includeTaskLocation` is not enabled,
			// all test will be skipped.
			if (testLocations !== undefined && testLocations.length !== 0) {
				if (t.location && testLocations?.includes(t.location.line)) {
					t.mode = "run";
					matchedLocations.push(t.location.line);
					hasLocationMatch = true;
				} else if (parentMatchedWithLocation) {
					t.mode = "run";
				} else if (t.type === "test") {
					t.mode = "skip";
				}
			}
			if (t.type === "test") {
				if (namePattern && !getTaskFullName(t).match(namePattern)) {
					t.mode = "skip";
				}
				if (testIds && !testIds.includes(t.id)) {
					t.mode = "skip";
				}
				if (testTagsFilter && !testTagsFilter(t.tags || [])) {
					t.mode = "skip";
				}
			} else if (t.type === "suite") {
				if (t.mode === "skip") {
					skipAllTasks(t);
				} else if (t.mode === "todo") {
					todoAllTasks(t);
				} else {
					traverseSuite(t, includeTask, hasLocationMatch);
				}
			}
		});
		// if all subtasks are skipped, mark as skip
		if (suite.mode === "run" || suite.mode === "queued") {
			if (suite.tasks.length && suite.tasks.every((i) => i.mode !== "run" && i.mode !== "queued")) {
				suite.mode = "skip";
			}
		}
	};
	traverseSuite(file, parentIsOnly, false);
	const nonMatching = testLocations?.filter((loc) => !matchedLocations.includes(loc));
	if (nonMatching && nonMatching.length !== 0) {
		const message = nonMatching.length === 1 ? `line ${nonMatching[0]}` : `lines ${nonMatching.join(", ")}`;
		if (file.result === undefined) {
			file.result = {
				state: "fail",
				errors: []
			};
		}
		if (file.result.errors === undefined) {
			file.result.errors = [];
		}
		file.result.errors.push(processError(new Error(`No test found in ${file.name} in ${message}`)));
	}
}
function getTaskFullName(task) {
	return `${task.suite ? `${getTaskFullName(task.suite)} ` : ""}${task.name}`;
}
function someTasksAreOnly(suite) {
	return suite.tasks.some((t) => t.mode === "only" || t.type === "suite" && someTasksAreOnly(t));
}
function skipAllTasks(suite) {
	suite.tasks.forEach((t) => {
		if (t.mode === "run" || t.mode === "queued") {
			t.mode = "skip";
			if (t.type === "suite") {
				skipAllTasks(t);
			}
		}
	});
}
function todoAllTasks(suite) {
	suite.tasks.forEach((t) => {
		if (t.mode === "run" || t.mode === "queued") {
			t.mode = "todo";
			if (t.type === "suite") {
				todoAllTasks(t);
			}
		}
	});
}
function checkAllowOnly(task, allowOnly) {
	if (allowOnly) {
		return;
	}
	const error = processError(new Error("[Vitest] Unexpected .only modifier. Remove it or pass --allowOnly argument to bypass this error"));
	task.result = {
		state: "fail",
		errors: [error]
	};
}
/* @__NO_SIDE_EFFECTS__ */
function generateHash(str) {
	let hash = 0;
	if (str.length === 0) {
		return `${hash}`;
	}
	for (let i = 0; i < str.length; i++) {
		const char = str.charCodeAt(i);
		hash = (hash << 5) - hash + char;
		hash = hash & hash;
	}
	return `${hash}`;
}
function calculateSuiteHash(parent) {
	parent.tasks.forEach((t, idx) => {
		t.id = `${parent.id}_${idx}`;
		if (t.type === "suite") {
			calculateSuiteHash(t);
		}
	});
}
function createFileTask(filepath, root, projectName, pool, viteEnvironment) {
	const path = relative(root, filepath);
	const file = {
		id: generateFileHash(path, projectName),
		name: path,
		fullName: path,
		type: "suite",
		mode: "queued",
		filepath,
		tasks: [],
		meta: Object.create(null),
		projectName,
		file: undefined,
		pool,
		viteEnvironment
	};
	file.file = file;
	return file;
}
/**
* Generate a unique ID for a file based on its path and project name
* @param file File relative to the root of the project to keep ID the same between different machines
* @param projectName The name of the test project
*/
/* @__NO_SIDE_EFFECTS__ */
function generateFileHash(file, projectName) {
	return /* @__PURE__ */ generateHash(`${file}${projectName || ""}`);
}
function findTestFileStackTrace(testFilePath, error) {
	// first line is the error message
	const lines = error.split("\n").slice(1);
	for (const line of lines) {
		const stack = parseSingleStack(line);
		if (stack && stack.file === testFilePath) {
			return stack;
		}
	}
}

/**
* Return a function for running multiple async operations with limited concurrency.
*/
function limitConcurrency(concurrency = Infinity) {
	// The number of currently active + pending tasks.
	let count = 0;
	// The head and tail of the pending task queue, built using a singly linked list.
	// Both head and tail are initially undefined, signifying an empty queue.
	// They both become undefined again whenever there are no pending tasks.
	let head;
	let tail;
	// A bookkeeping function executed whenever a task has been run to completion.
	const finish = () => {
		count--;
		// Check if there are further pending tasks in the queue.
		if (head) {
			// Allow the next pending task to run and pop it from the queue.
			head[0]();
			head = head[1];
			// The head may now be undefined if there are no further pending tasks.
			// In that case, set tail to undefined as well.
			tail = head && tail;
		}
	};
	const acquire = () => {
		let released = false;
		const release = () => {
			if (!released) {
				released = true;
				finish();
			}
		};
		if (count++ < concurrency) {
			return release;
		}
		return new Promise((resolve) => {
			if (tail) {
				// There are pending tasks, so append to the queue.
				tail = tail[1] = [() => resolve(release)];
			} else {
				// No other pending tasks, initialize the queue with a new tail and head.
				head = tail = [() => resolve(release)];
			}
		});
	};
	const limiterFn = (func, ...args) => {
		function run(release) {
			try {
				const result = func(...args);
				if (result instanceof Promise) {
					return result.finally(release);
				}
				release();
				return Promise.resolve(result);
			} catch (error) {
				release();
				return Promise.reject(error);
			}
		}
		const release = acquire();
		return release instanceof Promise ? release.then(run) : run(release);
	};
	return Object.assign(limiterFn, { acquire });
}

/**
* Partition in tasks groups by consecutive concurrent
*/
function partitionSuiteChildren(suite) {
	let tasksGroup = [];
	const tasksGroups = [];
	for (const c of suite.tasks) {
		if (tasksGroup.length === 0 || c.concurrent === tasksGroup[0].concurrent) {
			tasksGroup.push(c);
		} else {
			tasksGroups.push(tasksGroup);
			tasksGroup = [c];
		}
	}
	if (tasksGroup.length > 0) {
		tasksGroups.push(tasksGroup);
	}
	return tasksGroups;
}

function validateTags(config, tags) {
	if (!config.strictTags) {
		return;
	}
	const availableTags = new Set(config.tags.map((tag) => tag.name));
	for (const tag of tags) {
		if (!availableTags.has(tag)) {
			throw createNoTagsError(config.tags, tag);
		}
	}
}
function createNoTagsError(availableTags, tag, prefix = "tag") {
	if (!availableTags.length) {
		throw new Error(`The Vitest config does't define any "tags", cannot apply "${tag}" ${prefix} for this test. See: https://vitest.dev/guide/test-tags`);
	}
	throw new Error(`The ${prefix} "${tag}" is not defined in the configuration. Available tags are:\n${availableTags.map((t) => `- ${t.name}${t.description ? `: ${t.description}` : ""}`).join("\n")}`);
}
function createTagsFilter(tagsExpr, availableTags) {
	const matchers = tagsExpr.map((expr) => parseTagsExpression(expr, availableTags));
	return (testTags) => {
		return matchers.every((matcher) => matcher(testTags));
	};
}
function parseTagsExpression(expr, availableTags) {
	const tokens = tokenize(expr);
	const stream = new TokenStream(tokens, expr);
	const ast = parseOrExpression(stream, availableTags);
	if (stream.peek().type !== "EOF") {
		throw new Error(`Invalid tags expression: unexpected "${formatToken(stream.peek())}" in "${expr}"`);
	}
	return (tags) => evaluateNode(ast, tags);
}
function formatToken(token) {
	switch (token.type) {
		case "TAG": return token.value;
		default: return formatTokenType(token.type);
	}
}
function tokenize(expr) {
	const tokens = [];
	let i = 0;
	while (i < expr.length) {
		if (expr[i] === " " || expr[i] === "	") {
			i++;
			continue;
		}
		if (expr[i] === "(") {
			tokens.push({ type: "LPAREN" });
			i++;
			continue;
		}
		if (expr[i] === ")") {
			tokens.push({ type: "RPAREN" });
			i++;
			continue;
		}
		if (expr[i] === "!") {
			tokens.push({ type: "NOT" });
			i++;
			continue;
		}
		if (expr.slice(i, i + 2) === "&&") {
			tokens.push({ type: "AND" });
			i += 2;
			continue;
		}
		if (expr.slice(i, i + 2) === "||") {
			tokens.push({ type: "OR" });
			i += 2;
			continue;
		}
		if (/^and(?:\s|\)|$)/i.test(expr.slice(i))) {
			tokens.push({ type: "AND" });
			i += 3;
			continue;
		}
		if (/^or(?:\s|\)|$)/i.test(expr.slice(i))) {
			tokens.push({ type: "OR" });
			i += 2;
			continue;
		}
		if (/^not\s/i.test(expr.slice(i))) {
			tokens.push({ type: "NOT" });
			i += 3;
			continue;
		}
		let tag = "";
		while (i < expr.length && expr[i] !== " " && expr[i] !== "	" && expr[i] !== "(" && expr[i] !== ")" && expr[i] !== "!" && expr[i] !== "&" && expr[i] !== "|") {
			const remaining = expr.slice(i);
			// Only treat and/or/not as operators if we're at the start of a tag (after whitespace)
			// This allows tags like "demand", "editor", "cannot" to work correctly
			if (tag === "" && (/^and(?:\s|\)|$)/i.test(remaining) || /^or(?:\s|\)|$)/i.test(remaining) || /^not\s/i.test(remaining))) {
				break;
			}
			tag += expr[i];
			i++;
		}
		if (tag) {
			tokens.push({
				type: "TAG",
				value: tag
			});
		}
	}
	tokens.push({ type: "EOF" });
	return tokens;
}
class TokenStream {
	pos = 0;
	constructor(tokens, expr) {
		this.tokens = tokens;
		this.expr = expr;
	}
	peek() {
		return this.tokens[this.pos];
	}
	next() {
		return this.tokens[this.pos++];
	}
	expect(type) {
		const token = this.next();
		if (token.type !== type) {
			if (type === "RPAREN" && token.type === "EOF") {
				throw new Error(`Invalid tags expression: missing closing ")" in "${this.expr}"`);
			}
			throw new Error(`Invalid tags expression: expected "${formatTokenType(type)}" but got "${formatToken(token)}" in "${this.expr}"`);
		}
		return token;
	}
	unexpectedToken() {
		const token = this.peek();
		if (token.type === "EOF") {
			throw new Error(`Invalid tags expression: unexpected end of expression in "${this.expr}"`);
		}
		throw new Error(`Invalid tags expression: unexpected "${formatToken(token)}" in "${this.expr}"`);
	}
}
function formatTokenType(type) {
	switch (type) {
		case "TAG": return "tag";
		case "AND": return "and";
		case "OR": return "or";
		case "NOT": return "not";
		case "LPAREN": return "(";
		case "RPAREN": return ")";
		case "EOF": return "end of expression";
	}
}
function parseOrExpression(stream, availableTags) {
	let left = parseAndExpression(stream, availableTags);
	while (stream.peek().type === "OR") {
		stream.next();
		const right = parseAndExpression(stream, availableTags);
		left = {
			type: "or",
			left,
			right
		};
	}
	return left;
}
function parseAndExpression(stream, availableTags) {
	let left = parseUnaryExpression(stream, availableTags);
	while (stream.peek().type === "AND") {
		stream.next();
		const right = parseUnaryExpression(stream, availableTags);
		left = {
			type: "and",
			left,
			right
		};
	}
	return left;
}
function parseUnaryExpression(stream, availableTags) {
	if (stream.peek().type === "NOT") {
		stream.next();
		const operand = parseUnaryExpression(stream, availableTags);
		return {
			type: "not",
			operand
		};
	}
	return parsePrimaryExpression(stream, availableTags);
}
function parsePrimaryExpression(stream, availableTags) {
	const token = stream.peek();
	if (token.type === "LPAREN") {
		stream.next();
		const expr = parseOrExpression(stream, availableTags);
		stream.expect("RPAREN");
		return expr;
	}
	if (token.type === "TAG") {
		stream.next();
		const tagValue = token.value;
		const pattern = resolveTagPattern(tagValue, availableTags);
		return {
			type: "tag",
			value: tagValue,
			pattern
		};
	}
	stream.unexpectedToken();
}
function createWildcardRegex(pattern) {
	return new RegExp(`^${pattern.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*")}$`);
}
function resolveTagPattern(tagPattern, availableTags) {
	if (tagPattern.includes("*")) {
		const regex = createWildcardRegex(tagPattern);
		const hasMatch = availableTags.some((tag) => regex.test(tag.name));
		if (!hasMatch) {
			throw createNoTagsError(availableTags, tagPattern, "tag pattern");
		}
		return regex;
	}
	if (!availableTags.length || !availableTags.some((tag) => tag.name === tagPattern)) {
		throw createNoTagsError(availableTags, tagPattern, "tag pattern");
	}
	return null;
}
function evaluateNode(node, tags) {
	switch (node.type) {
		case "tag":
			if (node.pattern) {
				return tags.some((tag) => node.pattern.test(tag));
			}
			return tags.includes(node.value);
		case "not": return !evaluateNode(node.operand, tags);
		case "and": return evaluateNode(node.left, tags) && evaluateNode(node.right, tags);
		case "or": return evaluateNode(node.left, tags) || evaluateNode(node.right, tags);
	}
}

function isTestCase(s) {
	return s.type === "test";
}
function getTests(suite) {
	const tests = [];
	const arraySuites = toArray(suite);
	for (const s of arraySuites) {
		if (isTestCase(s)) {
			tests.push(s);
		} else {
			for (const task of s.tasks) {
				if (isTestCase(task)) {
					tests.push(task);
				} else {
					const taskTests = getTests(task);
					for (const test of taskTests) {
						tests.push(test);
					}
				}
			}
		}
	}
	return tests;
}
function getTasks(tasks = []) {
	return toArray(tasks).flatMap((s) => isTestCase(s) ? [s] : [s, ...getTasks(s.tasks)]);
}
function getSuites(suite) {
	return toArray(suite).flatMap((s) => s.type === "suite" ? [s, ...getSuites(s.tasks)] : []);
}
function hasTests(suite) {
	return toArray(suite).some((s) => s.tasks.some((c) => isTestCase(c) || hasTests(c)));
}
function hasFailed(suite) {
	return toArray(suite).some((s) => s.result?.state === "fail" || s.type === "suite" && hasFailed(s.tasks));
}
function getNames(task) {
	const names = [task.name];
	let current = task;
	while (current?.suite) {
		current = current.suite;
		if (current?.name) {
			names.unshift(current.name);
		}
	}
	if (current !== task.file) {
		names.unshift(task.file.name);
	}
	return names;
}
function getFullName(task, separator = " > ") {
	return getNames(task).join(separator);
}
function getTestName(task, separator = " > ") {
	return getNames(task).slice(1).join(separator);
}
function createTaskName(names, separator = " > ") {
	return names.filter((name) => name !== undefined).join(separator);
}

export { createChainable as a, createFileTask as b, calculateSuiteHash as c, createTagsFilter as d, createTaskName as e, findTestFileStackTrace as f, generateFileHash as g, generateHash as h, getFullName as i, getNames as j, getSuites as k, getTasks as l, getTestName as m, getTests as n, hasFailed as o, hasTests as p, interpretTaskModes as q, isTestCase as r, limitConcurrency as s, partitionSuiteChildren as t, someTasksAreOnly as u, validateTags as v, getChainableContext as w, createNoTagsError as x };
