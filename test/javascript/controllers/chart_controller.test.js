import { describe, it, expect, afterEach } from "vitest"
import ChartController from "controllers/chart_controller"
import { setupController, waitForNextFrame } from "../helpers/stimulus_helper"

describe("ChartController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
  })

  it("renders placeholder when no data", async () => {
    const html = `<div data-controller="chart" data-chart-data-value="{}" id="chart-el"></div>`
    context = await setupController(ChartController, html, "chart")

    expect(document.getElementById("chart-el").textContent).toContain("No chart data")
  })

  it("renders bars when data is provided", async () => {
    const data = JSON.stringify({ labels: ["Mon", "Tue", "Wed"], values: [10, 20, 15] })
    const html = `<div data-controller="chart" data-chart-data-value='${data}' id="chart-el"></div>`
    context = await setupController(ChartController, html, "chart")

    expect(document.getElementById("chart-el").querySelectorAll("div[style*='background']").length).toBeGreaterThan(0)
    expect(document.getElementById("chart-el").textContent).toContain("Mon")
    expect(document.getElementById("chart-el").textContent).toContain("20")
  })

  it("clears content on disconnect", async () => {
    const data = JSON.stringify({ labels: ["Mon"], values: [10] })
    const html = `<div data-controller="chart" data-chart-data-value='${data}' id="chart-el"></div>`
    context = await setupController(ChartController, html, "chart")

    const el = document.getElementById("chart-el")
    expect(el.innerHTML).not.toBe("")

    el.removeAttribute("data-controller")
    context.application.stop()
    await waitForNextFrame()
    context = null
  })
})
