import { describe, it, expect, afterEach, vi } from "vitest"
import FulfillmentCommentController from "controllers/fulfillment_comment_controller"
import { setupController, click, waitForNextFrame } from "../helpers/stimulus_helper"

describe("FulfillmentCommentController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div data-controller="fulfillment-comment"
         data-fulfillment-comment-url-value="/admin/orders/1/comments">
      <div id="order_comments">
        <ul></ul>
      </div>
      <form data-action="submit->fulfillment-comment#submit">
        <meta name="csrf-token" content="test-token">
        <input type="text" name="comment[note]" id="comment_note" value="Test comment">
        <button type="submit" class="comment-submit-button" id="submit-btn">Submit</button>
      </form>
    </div>
  `

  it("appends comment to list on successful response", async () => {
    const mockResponse = { ok: true, json: () => Promise.resolve({ note: "Test comment" }) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentCommentController, html, "fulfillment-comment")

    const form = document.querySelector("form")
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))
    await waitForNextFrame()

    const items = document.querySelectorAll("#order_comments li")
    expect(items.length).toBe(1)
    expect(items[0].textContent).toContain("Test comment")
  })

  it("clears the note input after successful submission", async () => {
    const mockResponse = { ok: true, json: () => Promise.resolve({ note: "Test comment" }) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentCommentController, html, "fulfillment-comment")

    const form = document.querySelector("form")
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))
    await waitForNextFrame()

    expect(document.getElementById("comment_note").value).toBe("")
  })

  it("disables submit button during request", async () => {
    let resolveResponse
    const responsePromise = new Promise((resolve) => { resolveResponse = resolve })
    vi.spyOn(globalThis, "fetch").mockReturnValue(responsePromise)

    context = await setupController(FulfillmentCommentController, html, "fulfillment-comment")

    const form = document.querySelector("form")
    const btn = document.getElementById("submit-btn")
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))

    await waitForNextFrame()
    expect(btn.disabled).toBe(true)

    resolveResponse({ ok: true, json: () => Promise.resolve({ note: "done" }) })
    await waitForNextFrame()
    await waitForNextFrame()
    expect(btn.disabled).toBe(false)
  })

  it("uses textContent to prevent XSS injection", async () => {
    const malicious = '<img src=x onerror=alert(1)>'
    const mockResponse = { ok: true, json: () => Promise.resolve({ note: malicious }) }
    vi.spyOn(globalThis, "fetch").mockResolvedValue(mockResponse)

    context = await setupController(FulfillmentCommentController, html, "fulfillment-comment")

    const form = document.querySelector("form")
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))
    await waitForNextFrame()

    const li = document.querySelector("#order_comments li")
    expect(li.innerHTML).not.toContain("<img")
    expect(li.textContent).toContain(malicious)
  })
})
