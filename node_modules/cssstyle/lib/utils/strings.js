// Forked from https://github.com/jsdom/jsdom/blob/main/lib/jsdom/living/helpers/strings.js

"use strict";

/**
 * Converts a string to ASCII lowercase.
 *
 * @see https://infra.spec.whatwg.org/#ascii-lowercase
 * @param {string} s - The string to convert.
 * @returns {string} The converted string.
 */
function asciiLowercase(s) {
  if (!/[^\x00-\x7f]/.test(s)) {
    return s.toLowerCase();
  }
  const len = s.length;
  const out = new Array(len);
  for (let i = 0; i < len; i++) {
    const code = s.charCodeAt(i);
    // If the character is between 'A' (65) and 'Z' (90), convert using bitwise OR with 32
    out[i] = code >= 65 && code <= 90 ? String.fromCharCode(code | 32) : s[i];
  }
  return out.join("");
}

module.exports = {
  asciiLowercase
};
