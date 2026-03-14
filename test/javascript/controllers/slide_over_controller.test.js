import { describe, it, expect, afterEach } from "vitest"
import SlideOverController from "controllers/slide_over_controller"
import { setupController, click, keydown } from "../helpers/stimulus_helper"

describe("SlideOverController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
  })

  const html = `
    <div data-controller="slide-over">
      <button data-action="click->slide-over#open" id="open-btn">Open</button>
      <div data-slide-over-target="overlay" id="overlay"></div>
      <div data-slide-over-target="panel" class="slide-over" id="panel">
        <button data-action="click->slide-over#close" id="close-btn">Close</button>
        <input type="text" id="first-input">
      </div>
    </div>
  `

  it("opens the panel on open action", async () => {
    context = await setupController(SlideOverController, html, "slide-over")

    click(document.getElementById("open-btn"))
    expect(document.getElementById("panel").classList.contains("open")).toBe(true)
    expect(document.getElementById("overlay").classList.contains("open")).toBe(true)
  })

  it("closes the panel on close action", async () => {
    context = await setupController(SlideOverController, html, "slide-over")

    click(document.getElementById("open-btn"))
    click(document.getElementById("close-btn"))
    expect(document.getElementById("panel").classList.contains("open")).toBe(false)
  })

  it("closes on Escape key", async () => {
    context = await setupController(SlideOverController, html, "slide-over")

    click(document.getElementById("open-btn"))
    keydown(document, "Escape")
    expect(document.getElementById("panel").classList.contains("open")).toBe(false)
  })

  it("traps focus within the panel when Tab is pressed on last element", async () => {
    const trapHtml = `
      <div data-controller="slide-over">
        <button data-action="click->slide-over#open" id="open-btn">Open</button>
        <div data-slide-over-target="panel" class="slide-over" id="panel">
          <button id="first-btn">First</button>
          <input type="text" id="mid-input">
          <button data-action="click->slide-over#close" id="last-btn">Close</button>
        </div>
      </div>
    `
    context = await setupController(SlideOverController, trapHtml, "slide-over")
    click(document.getElementById("open-btn"))

    document.getElementById("last-btn").focus()
    expect(document.activeElement.id).toBe("last-btn")

    keydown(document, "Tab")
    expect(document.activeElement.id).toBe("first-btn")
  })

  it("traps focus backwards with Shift+Tab on first element", async () => {
    const trapHtml = `
      <div data-controller="slide-over">
        <button data-action="click->slide-over#open" id="open-btn">Open</button>
        <div data-slide-over-target="panel" class="slide-over" id="panel">
          <button id="first-btn">First</button>
          <input type="text" id="mid-input">
          <button data-action="click->slide-over#close" id="last-btn">Close</button>
        </div>
      </div>
    `
    context = await setupController(SlideOverController, trapHtml, "slide-over")
    click(document.getElementById("open-btn"))

    document.getElementById("first-btn").focus()
    expect(document.activeElement.id).toBe("first-btn")

    keydown(document, "Tab", { shiftKey: true })
    expect(document.activeElement.id).toBe("last-btn")
  })
})
