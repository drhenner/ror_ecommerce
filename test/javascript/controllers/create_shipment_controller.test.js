import { describe, it, expect, afterEach, vi } from "vitest"
import CreateShipmentController from "controllers/create_shipment_controller"
import { setupController, click, waitForNextFrame } from "../helpers/stimulus_helper"

describe("CreateShipmentController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div data-controller="create-shipment">
      <meta name="csrf-token" content="test-token">
      <div data-create-shipment-target="box" id="shipment-box">Original content</div>
      <button data-action="click->create-shipment#create" data-url="/admin/orders/1/create_shipment" id="create-btn">Create Shipment</button>
    </div>
  `

  it("replaces box content with response HTML on success", async () => {
    const mockResponse = { ok: true, text: () => Promise.resolve("<p>Shipment created</p>") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(CreateShipmentController, html, "create-shipment")

    click(document.getElementById("create-btn"))
    await waitForNextFrame()
    await waitForNextFrame()

    expect(document.getElementById("shipment-box").innerHTML).toContain("Shipment created")
  })

  it("sends PUT request with CSRF token", async () => {
    const mockResponse = { ok: true, text: () => Promise.resolve("ok") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(CreateShipmentController, html, "create-shipment")

    click(document.getElementById("create-btn"))
    await waitForNextFrame()

    expect(globalThis.fetch).toHaveBeenCalledWith(
      "/admin/orders/1/create_shipment",
      expect.objectContaining({ method: "PUT" })
    )
  })

  it("disables button during request to prevent double clicks", async () => {
    let resolveResponse
    const responsePromise = new Promise((resolve) => { resolveResponse = resolve })
    vi.spyOn(globalThis, "fetch").mockReturnValue(responsePromise)

    context = await setupController(CreateShipmentController, html, "create-shipment")

    const btn = document.getElementById("create-btn")
    click(btn)
    await waitForNextFrame()
    expect(btn.disabled).toBe(true)

    resolveResponse({ ok: true, text: () => Promise.resolve("done") })
    await waitForNextFrame()
    await waitForNextFrame()
    expect(btn.disabled).toBe(false)
  })

  it("ignores clicks while already submitting", async () => {
    let resolveResponse
    const responsePromise = new Promise((resolve) => { resolveResponse = resolve })
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockReturnValue(responsePromise)

    context = await setupController(CreateShipmentController, html, "create-shipment")

    const btn = document.getElementById("create-btn")
    click(btn)
    click(btn)
    await waitForNextFrame()

    expect(fetchSpy).toHaveBeenCalledTimes(1)
    resolveResponse({ ok: true, text: () => Promise.resolve("done") })
  })

  it("does not update box on non-ok response", async () => {
    const mockResponse = { ok: false, text: () => Promise.resolve("error") }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(CreateShipmentController, html, "create-shipment")

    click(document.getElementById("create-btn"))
    await waitForNextFrame()
    await waitForNextFrame()

    expect(document.getElementById("shipment-box").innerHTML).toBe("Original content")
  })

  it("aborts in-flight request on disconnect", async () => {
    let fetchSignal
    vi.spyOn(globalThis, "fetch").mockImplementation((_url, opts) => {
      fetchSignal = opts?.signal
      return new Promise(() => {})
    })

    context = await setupController(CreateShipmentController, html, "create-shipment")

    click(document.getElementById("create-btn"))
    await waitForNextFrame()

    expect(fetchSignal).toBeDefined()
    expect(fetchSignal.aborted).toBe(false)

    context.element.removeAttribute("data-controller")
    await waitForNextFrame()
    expect(fetchSignal.aborted).toBe(true)
  })
})
