import { g as globalApis } from './constants.CPYnjOGj.js';
import { i as index } from './index.DlDSLQD3.js';
import './test.CTcmp4Su.js';
import '@vitest/runner';
import '@vitest/utils/helpers';
import '@vitest/utils/timers';
import './benchmark.D0SlKNbZ.js';
import '@vitest/runner/utils';
import './utils.BX5Fg8C4.js';
import '@vitest/expect';
import '@vitest/utils/error';
import 'pathe';
import '@vitest/snapshot';
import '@vitest/spy';
import '@vitest/utils/offset';
import '@vitest/utils/source-map';
import './_commonjsHelpers.D26ty3Ew.js';
import './rpc.MzXet3jl.js';
import './index.Chj8NDwU.js';
import './evaluatedModules.Dg1zASAC.js';
import 'vite/module-runner';
import 'expect-type';

function registerApiGlobally() {
	globalApis.forEach((api) => {
		// @ts-expect-error I know what I am doing :P
		globalThis[api] = index[api];
	});
}

export { registerApiGlobally };
