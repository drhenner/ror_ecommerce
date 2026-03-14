import { describe, it, expect, afterEach, vi } from "vitest"
import FulfillmentInvoiceController from "controllers/fulfillment_invoice_controller"
import { setupController, click, waitForNextFrame } from "../helpers/stimulus_helper"

describe("FulfillmentInvoiceController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div>
      <meta name="csrf-token" content="test-token">
      <div id="invoice-line-99"
           data-controller="fulfillment-invoice"
           data-fulfillment-invoice-invoice-id-value="99"
           data-fulfillment-invoice-order-id-value="1"
           data-fulfillment-invoice-order-url-value="/admin/fulfillment/orders/1">
        <button data-action="click->fulfillment-invoice#capture" id="capture-btn">Capture</button>
        <button data-action="click->fulfillment-invoice#cancel" id="cancel-btn">Cancel</button>
      </div>
    </div>
  `

  it("sends PUT with invoice_id and amount on capture", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    const mockResponse = { ok: true, text: () => Promise.resolve("<span>Captured</span>") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    click(document.getElementById("capture-btn"))
    await waitForNextFrame()

    expect(globalThis.fetch).toHaveBeenCalledWith(
      "/admin/fulfillment/orders/1",
      expect.objectContaining({ method: "PUT" })
    )
  })

  it("sends DELETE on cancel", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    const mockResponse = { ok: true, text: () => Promise.resolve("<span>Cancelled</span>") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    click(document.getElementById("cancel-btn"))
    await waitForNextFrame()

    expect(globalThis.fetch).toHaveBeenCalledWith(
      "/admin/fulfillment/orders/1",
      expect.objectContaining({ method: "DELETE" })
    )
  })

  it("does nothing if user cancels confirm dialog", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(false)
    const fetchSpy = vi.spyOn(globalThis, "fetch")

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    click(document.getElementById("capture-btn"))
    await waitForNextFrame()

    expect(fetchSpy).not.toHaveBeenCalled()
  })

  it("updates invoice line HTML on success", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    const mockResponse = { ok: true, text: () => Promise.resolve("<span>Payment captured</span>") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    click(document.getElementById("capture-btn"))
    await waitForNextFrame()
    await waitForNextFrame()

    expect(document.getElementById("invoice-line-99").innerHTML).toContain("Payment captured")
  })

  it("prevents double-clicks while submitting", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    let resolveResponse
    const responsePromise = new Promise((resolve) => { resolveResponse = resolve })
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockReturnValue(responsePromise)

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    click(document.getElementById("capture-btn"))
    click(document.getElementById("capture-btn"))
    await waitForNextFrame()

    expect(fetchSpy).toHaveBeenCalledTimes(1)
    resolveResponse({ ok: true, text: () => Promise.resolve("done") })
  })

  it("re-enables button after request completes", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    const mockResponse = { ok: true, text: () => Promise.resolve("ok") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentInvoiceController, html, "fulfillment-invoice")

    const btn = document.getElementById("capture-btn")
    click(btn)
    await waitForNextFrame()
    await waitForNextFrame()

    expect(btn.disabled).toBe(false)
  })
})
