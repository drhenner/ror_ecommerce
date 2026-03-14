import { describe, it, expect, afterEach, vi } from "vitest"
import SearchFilterController from "controllers/search_filter_controller"
import { setupController, type } from "../helpers/stimulus_helper"

describe("SearchFilterController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <form data-controller="search-filter" data-search-filter-delay-value="50" id="filter-form">
      <input type="text" data-action="input->search-filter#filter" id="search-input">
    </form>
  `

  it("submits form after debounce delay", async () => {
    context = await setupController(SearchFilterController, html, "search-filter")

    const form = document.getElementById("filter-form")
    const submitSpy = vi.fn((e) => e.preventDefault())
    form.addEventListener("submit", submitSpy)

    type(document.getElementById("search-input"), "test")

    await new Promise((r) => setTimeout(r, 30))
    expect(submitSpy).not.toHaveBeenCalled()

    await new Promise((r) => setTimeout(r, 40))
    expect(submitSpy).toHaveBeenCalledTimes(1)
  })

  it("resets timer on new input", async () => {
    context = await setupController(SearchFilterController, html, "search-filter")

    const form = document.getElementById("filter-form")
    const submitSpy = vi.fn((e) => e.preventDefault())
    form.addEventListener("submit", submitSpy)

    type(document.getElementById("search-input"), "te")
    await new Promise((r) => setTimeout(r, 30))
    type(document.getElementById("search-input"), "test")

    await new Promise((r) => setTimeout(r, 70))
    expect(submitSpy).toHaveBeenCalledTimes(1)
  })
})
