import { describe, it, expect, afterEach, vi, beforeEach } from "vitest"
import AutocompleteController from "controllers/autocomplete_controller"
import { setupController, type, keydown, waitForNextFrame } from "../helpers/stimulus_helper"

describe("AutocompleteController", () => {
  let context

  beforeEach(() => {
    vi.useFakeTimers({ shouldAdvanceTime: true })
  })

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
    vi.useRealTimers()
  })

  const html = `
    <div data-controller="autocomplete" data-autocomplete-url-value="/search" data-autocomplete-min-length-value="2">
      <input type="text" data-autocomplete-target="input" data-action="input->autocomplete#onInput keydown->autocomplete#onKeydown" id="ac-input">
      <input type="hidden" data-autocomplete-target="hidden" id="ac-hidden">
      <div data-autocomplete-target="results" id="ac-results" style="display:none"></div>
    </div>
  `

  it("does not fetch when input is below minLength", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch")
    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "a")
    await vi.advanceTimersByTimeAsync(300)

    expect(fetchSpy).not.toHaveBeenCalled()
  })

  it("fetches suggestions when input reaches minLength", async () => {
    const mockResponse = { ok: true, json: () => Promise.resolve([{ label: "Widget", value: "1" }]) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "wi")
    await vi.advanceTimersByTimeAsync(300)
    await waitForNextFrame()

    expect(globalThis.fetch).toHaveBeenCalled()
    expect(document.getElementById("ac-results").style.display).toBe("block")
    expect(document.getElementById("ac-results").children.length).toBe(1)
  })

  it("closes results on Escape", async () => {
    const mockResponse = { ok: true, json: () => Promise.resolve([{ label: "Widget", value: "1" }]) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "wi")
    await vi.advanceTimersByTimeAsync(300)
    await waitForNextFrame()

    keydown(document.getElementById("ac-input"), "Escape")
    expect(document.getElementById("ac-results").style.display).toBe("none")
  })

  it("closes results when clicking outside the controller element", async () => {
    const outerHtml = `
      <div>
        <div id="outside">outside</div>
        <div data-controller="autocomplete" data-autocomplete-url-value="/search" data-autocomplete-min-length-value="2">
          <input type="text" data-autocomplete-target="input" data-action="input->autocomplete#onInput keydown->autocomplete#onKeydown" id="ac-input">
          <input type="hidden" data-autocomplete-target="hidden" id="ac-hidden">
          <div data-autocomplete-target="results" id="ac-results" style="display:none"></div>
        </div>
      </div>
    `
    const mockResponse = { ok: true, json: () => Promise.resolve([{ label: "Widget", value: "1" }]) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(AutocompleteController, outerHtml, "autocomplete")

    type(document.getElementById("ac-input"), "wi")
    await vi.advanceTimersByTimeAsync(300)
    await waitForNextFrame()

    expect(document.getElementById("ac-results").style.display).toBe("block")

    document.getElementById("outside").dispatchEvent(new MouseEvent("click", { bubbles: true }))
    expect(document.getElementById("ac-results").style.display).toBe("none")
  })

  it("safely renders items with double quotes in value/label (no attribute injection)", async () => {
    const malicious = [{ label: 'A" onclick="alert(1)', value: '1" data-x="evil' }]
    const mockResponse = { ok: true, json: () => Promise.resolve(malicious) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "test")
    await vi.advanceTimersByTimeAsync(300)
    await waitForNextFrame()

    const results = document.getElementById("ac-results")
    const item = results.children[0]
    expect(item).toBeDefined()
    expect(item.dataset.label).toBe('A" onclick="alert(1)')
    expect(item.dataset.value).toBe('1" data-x="evil')
    expect(item.getAttribute("onclick")).toBeNull()
    expect(item.textContent).toBe('A" onclick="alert(1)')
  })

  it("handles null/undefined values in server response", async () => {
    const items = [{ label: null, value: undefined }]
    const mockResponse = { ok: true, json: () => Promise.resolve(items) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "test")
    await vi.advanceTimersByTimeAsync(300)
    await waitForNextFrame()

    const results = document.getElementById("ac-results")
    expect(results.children.length).toBe(1)
    expect(results.children[0].textContent).toBe("")
    expect(results.children[0].dataset.value).toBe("")
  })

  it("aborts in-flight request on disconnect", async () => {
    let fetchSignal
    vi.spyOn(globalThis, "fetch").mockImplementation((_url, opts) => {
      fetchSignal = opts.signal
      return new Promise(() => {})
    })

    context = await setupController(AutocompleteController, html, "autocomplete")

    type(document.getElementById("ac-input"), "test")
    await vi.advanceTimersByTimeAsync(300)

    expect(fetchSignal).toBeDefined()
    expect(fetchSignal.aborted).toBe(false)

    context.element.removeAttribute("data-controller")
    await vi.advanceTimersByTimeAsync(0)
    expect(fetchSignal.aborted).toBe(true)
  })
})
