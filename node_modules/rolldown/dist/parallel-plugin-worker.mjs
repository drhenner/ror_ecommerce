import { n as __toESM, t as require_binding } from "./shared/binding-C5G6_6ql.mjs";
import "./shared/normalize-string-or-regex-C5RWbu3O.mjs";
import { n as PluginContextData, r as bindingifyPlugin } from "./shared/bindingify-input-options-Cu7pt6SZ.mjs";
import "./shared/error-CP8smW_P.mjs";
import "./shared/parse-B3SIKejW.mjs";
import { parentPort, workerData } from "node:worker_threads";
//#region src/parallel-plugin-worker.ts
var import_binding = /* @__PURE__ */ __toESM(require_binding(), 1);
const { registryId, pluginInfos, threadNumber } = workerData;
(async () => {
	try {
		(0, import_binding.registerPlugins)(registryId, await Promise.all(pluginInfos.map(async (pluginInfo) => {
			const definePluginImpl = (await import(pluginInfo.fileUrl)).default;
			const plugin = await definePluginImpl(pluginInfo.options, { threadNumber });
			return {
				index: pluginInfo.index,
				plugin: bindingifyPlugin(plugin, {}, {}, new PluginContextData(() => {}, {}, [], []), [], () => {}, "info", false)
			};
		})));
		parentPort.postMessage({ type: "success" });
	} catch (error) {
		parentPort.postMessage({
			type: "error",
			error
		});
	} finally {
		parentPort.unref();
	}
})();
//#endregion
export {};
