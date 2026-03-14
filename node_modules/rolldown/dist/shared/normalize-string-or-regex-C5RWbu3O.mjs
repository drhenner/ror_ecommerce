import { n as __toESM, t as require_binding } from "./binding-C5G6_6ql.mjs";
import { c as logPluginError, n as error } from "./logs-D80CXhvg.mjs";
//#region src/builtin-plugin/utils.ts
var import_binding = /* @__PURE__ */ __toESM(require_binding(), 1);
var BuiltinPlugin = class {
	/** Vite-specific option to control plugin ordering */
	enforce;
	constructor(name, _options) {
		this.name = name;
		this._options = _options;
	}
};
function makeBuiltinPluginCallable(plugin) {
	let callablePlugin = new import_binding.BindingCallableBuiltinPlugin(bindingifyBuiltInPlugin(plugin));
	const wrappedPlugin = plugin;
	for (const key in callablePlugin) wrappedPlugin[key] = async function(...args) {
		try {
			return await callablePlugin[key](...args);
		} catch (e) {
			if (e instanceof Error && !e.stack?.includes("at ")) Error.captureStackTrace(e, wrappedPlugin[key]);
			return error(logPluginError(e, plugin.name, {
				hook: key,
				id: key === "transform" ? args[2] : void 0
			}));
		}
	};
	return wrappedPlugin;
}
function bindingifyBuiltInPlugin(plugin) {
	return {
		__name: plugin.name,
		options: plugin._options
	};
}
function bindingifyManifestPlugin(plugin, pluginContextData) {
	const { isOutputOptionsForLegacyChunks, ...options } = plugin._options;
	return {
		__name: plugin.name,
		options: {
			...options,
			isLegacy: isOutputOptionsForLegacyChunks ? (opts) => {
				return isOutputOptionsForLegacyChunks(pluginContextData.getOutputOptions(opts));
			} : void 0
		}
	};
}
//#endregion
//#region src/utils/normalize-string-or-regex.ts
function normalizedStringOrRegex(pattern) {
	if (!pattern) return;
	if (!isReadonlyArray(pattern)) return [pattern];
	return pattern;
}
function isReadonlyArray(input) {
	return Array.isArray(input);
}
//#endregion
export { makeBuiltinPluginCallable as a, bindingifyManifestPlugin as i, BuiltinPlugin as n, bindingifyBuiltInPlugin as r, normalizedStringOrRegex as t };
