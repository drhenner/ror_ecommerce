import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "jsdom",
    include: ["test/javascript/**/*.test.js"],
    globals: true,
    setupFiles: ["test/javascript/helpers/setup.js"],
  },
  resolve: {
    alias: {
      controllers: "/app/javascript/controllers",
    },
  },
})
