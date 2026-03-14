import { describe, it, expect, afterEach, vi } from "vitest"
import FlashController from "controllers/flash_controller"
import { setupController, click } from "../helpers/stimulus_helper"

describe("FlashController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div data-controller="flash" data-flash-delay-value="100" id="flash-el">
      <span>Notice message</span>
      <button data-action="click->flash#dismiss" id="dismiss-btn">&times;</button>
    </div>
  `

  it("adds flash-out class after delay", async () => {
    context = await setupController(FlashController, html, "flash")

    await new Promise((r) => setTimeout(r, 150))
    expect(document.getElementById("flash-el").classList.contains("flash-out")).toBe(true)
  })

  it("adds flash-out class on manual dismiss click", async () => {
    context = await setupController(FlashController, html, "flash")

    click(document.getElementById("dismiss-btn"))
    expect(document.getElementById("flash-el").classList.contains("flash-out")).toBe(true)
  })

  it("only adds flash-out once when dismiss is called multiple times", async () => {
    context = await setupController(FlashController, html, "flash")

    const el = document.getElementById("flash-el")
    const addSpy = vi.spyOn(el.classList, "add")

    click(document.getElementById("dismiss-btn"))
    click(document.getElementById("dismiss-btn"))

    const flashOutCalls = addSpy.mock.calls.filter((args) => args[0] === "flash-out")
    expect(flashOutCalls.length).toBe(1)
  })
})
