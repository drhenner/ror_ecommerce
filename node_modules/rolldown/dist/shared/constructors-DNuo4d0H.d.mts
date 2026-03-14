import { C as BindingViteModulePreloadPolyfillPluginConfig, E as BindingViteResolvePluginConfig, T as BindingViteReporterPluginConfig, b as BindingViteImportGlobPluginConfig, l as BindingIsolatedDeclarationPluginConfig, s as BindingEsmExternalRequirePluginConfig, v as BindingViteBuildImportAnalysisPluginConfig, w as BindingViteReactRefreshWrapperPluginConfig, x as BindingViteJsonPluginConfig, y as BindingViteDynamicImportVarsPluginConfig } from "./binding-BohGL_65.mjs";
import { N as BuiltinPlugin, Vt as StringOrRegExp } from "./define-config-cG45vHwf.mjs";

//#region src/builtin-plugin/constructors.d.ts
declare function viteModulePreloadPolyfillPlugin(config?: BindingViteModulePreloadPolyfillPluginConfig): BuiltinPlugin;
type DynamicImportVarsPluginConfig = Omit<BindingViteDynamicImportVarsPluginConfig, "include" | "exclude"> & {
  include?: StringOrRegExp | StringOrRegExp[];
  exclude?: StringOrRegExp | StringOrRegExp[];
};
declare function viteDynamicImportVarsPlugin(config?: DynamicImportVarsPluginConfig): BuiltinPlugin;
declare function viteImportGlobPlugin(config?: BindingViteImportGlobPluginConfig): BuiltinPlugin;
declare function viteReporterPlugin(config: BindingViteReporterPluginConfig): BuiltinPlugin;
declare function viteWasmFallbackPlugin(): BuiltinPlugin;
declare function viteLoadFallbackPlugin(): BuiltinPlugin;
declare function viteJsonPlugin(config: BindingViteJsonPluginConfig): BuiltinPlugin;
declare function viteBuildImportAnalysisPlugin(config: BindingViteBuildImportAnalysisPluginConfig): BuiltinPlugin;
declare function viteResolvePlugin(config: Omit<BindingViteResolvePluginConfig, "yarnPnp">): BuiltinPlugin;
declare function isolatedDeclarationPlugin(config?: BindingIsolatedDeclarationPluginConfig): BuiltinPlugin;
declare function viteWebWorkerPostPlugin(): BuiltinPlugin;
/**
* A plugin that converts CommonJS require() calls for external dependencies into ESM import statements.
*
* @see https://rolldown.rs/builtin-plugins/esm-external-require
* @category Builtin Plugins
*/
declare function esmExternalRequirePlugin(config?: BindingEsmExternalRequirePluginConfig): BuiltinPlugin;
type ViteReactRefreshWrapperPluginConfig = Omit<BindingViteReactRefreshWrapperPluginConfig, "include" | "exclude"> & {
  include?: StringOrRegExp | StringOrRegExp[];
  exclude?: StringOrRegExp | StringOrRegExp[];
};
declare function viteReactRefreshWrapperPlugin(config: ViteReactRefreshWrapperPluginConfig): BuiltinPlugin;
//#endregion
export { viteImportGlobPlugin as a, viteModulePreloadPolyfillPlugin as c, viteResolvePlugin as d, viteWasmFallbackPlugin as f, viteDynamicImportVarsPlugin as i, viteReactRefreshWrapperPlugin as l, isolatedDeclarationPlugin as n, viteJsonPlugin as o, viteWebWorkerPostPlugin as p, viteBuildImportAnalysisPlugin as r, viteLoadFallbackPlugin as s, esmExternalRequirePlugin as t, viteReporterPlugin as u };