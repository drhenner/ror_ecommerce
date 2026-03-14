import { describe, it, expect, afterEach, vi } from "vitest"
import VariantCostController from "controllers/variant_cost_controller"
import { setupController, waitForNextFrame } from "../helpers/stimulus_helper"

describe("VariantCostController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div data-controller="variant-cost" data-variant-cost-url-value="/admin/variants">
      <div class="variant-row">
        <select data-action="change->variant-cost#change" id="variant-select">
          <option value="">Select…</option>
          <option value="42">Widget</option>
        </select>
        <input type="text" name="item[cost]" id="cost-input" value="">
      </div>
    </div>
  `

  it("fetches variant cost and prefills the input on selection", async () => {
    const mockResponse = { ok: true, json: () => Promise.resolve({ cost: "9.99" }) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    expect(globalThis.fetch).toHaveBeenCalledWith(
      expect.stringContaining("/admin/variants/42"),
      expect.objectContaining({ headers: { Accept: "application/json" } })
    )
    await waitForNextFrame()
    expect(document.getElementById("cost-input").value).toBe("9.99")
  })

  it("does nothing when blank option is selected", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch")
    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = ""
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    expect(fetchSpy).not.toHaveBeenCalled()
  })

  it("handles fetch errors gracefully", async () => {
    vi.spyOn(globalThis, "fetch").mockRejectedValue(new Error("Network error"))
    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    expect(document.getElementById("cost-input").value).toBe("")
  })

  it("does not update cost on non-ok response", async () => {
    const mockResponse = { ok: false, json: () => Promise.resolve({ cost: "0.00" }) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()
    await waitForNextFrame()

    expect(document.getElementById("cost-input").value).toBe("")
  })

  it("aborts previous request when selection changes rapidly", async () => {
    let signals = []
    vi.spyOn(globalThis, "fetch").mockImplementation((_url, opts) => {
      signals.push(opts.signal)
      return new Promise(() => {})
    })

    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    expect(signals.length).toBe(2)
    expect(signals[0].aborted).toBe(true)
    expect(signals[1].aborted).toBe(false)
  })

  it("aborts in-flight request on disconnect", async () => {
    let fetchSignal
    vi.spyOn(globalThis, "fetch").mockImplementation((_url, opts) => {
      fetchSignal = opts.signal
      return new Promise(() => {})
    })

    context = await setupController(VariantCostController, html, "variant-cost")

    const select = document.getElementById("variant-select")
    select.value = "42"
    select.dispatchEvent(new Event("change", { bubbles: true }))
    await waitForNextFrame()

    expect(fetchSignal.aborted).toBe(false)

    context.element.removeAttribute("data-controller")
    await waitForNextFrame()
    expect(fetchSignal.aborted).toBe(true)
  })
})
