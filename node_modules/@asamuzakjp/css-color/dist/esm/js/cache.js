import { LRUCache } from "lru-cache";
import { valueToJsonString } from "./util.js";
const MAX_CACHE = 4096;
class CacheItem {
  /* private */
  #isNull;
  #item;
  /**
   * constructor
   */
  constructor(item, isNull = false) {
    this.#item = item;
    this.#isNull = !!isNull;
  }
  get item() {
    return this.#item;
  }
  get isNull() {
    return this.#isNull;
  }
}
class NullObject extends CacheItem {
  /**
   * constructor
   */
  constructor() {
    super(/* @__PURE__ */ Symbol("null"), true);
  }
}
const lruCache = new LRUCache({
  max: MAX_CACHE
});
const setCache = (key, value) => {
  if (key) {
    if (value === null) {
      lruCache.set(key, new NullObject());
    } else if (value instanceof CacheItem) {
      lruCache.set(key, value);
    } else {
      lruCache.set(key, new CacheItem(value));
    }
  }
};
const getCache = (key) => {
  if (key && lruCache.has(key)) {
    const item = lruCache.get(key);
    if (item instanceof CacheItem) {
      return item;
    }
    lruCache.delete(key);
    return false;
  }
  return false;
};
const createCacheKey = (keyData, opt = {}) => {
  const { customProperty = {}, dimension = {} } = opt;
  let cacheKey = "";
  if (keyData && Object.keys(keyData).length && typeof customProperty.callback !== "function" && typeof dimension.callback !== "function") {
    keyData.opt = valueToJsonString(opt);
    cacheKey = valueToJsonString(keyData);
  }
  return cacheKey;
};
export {
  CacheItem,
  NullObject,
  createCacheKey,
  getCache,
  lruCache,
  setCache
};
//# sourceMappingURL=cache.js.map
