import { describe, it, expect, afterEach, vi } from "vitest"
import ConfirmController from "controllers/confirm_controller"
import { setupController, click } from "../helpers/stimulus_helper"

describe("ConfirmController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <div data-controller="confirm" data-confirm-message-value="Delete this item?">
      <button data-action="click->confirm#confirm" id="delete-btn">Delete</button>
    </div>
  `

  it("prevents action when user cancels confirm dialog", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(false)
    context = await setupController(ConfirmController, html, "confirm")

    const btn = document.getElementById("delete-btn")
    const clickHandler = vi.fn()
    btn.addEventListener("click", clickHandler)

    click(btn)
    expect(window.confirm).toHaveBeenCalledWith("Delete this item?")
  })

  it("allows action when user confirms", async () => {
    vi.spyOn(window, "confirm").mockReturnValue(true)
    context = await setupController(ConfirmController, html, "confirm")

    const btn = document.getElementById("delete-btn")
    click(btn)
    expect(window.confirm).toHaveBeenCalledWith("Delete this item?")
  })
})
