import { describe, it, expect, afterEach, vi } from "vitest"
import SortableTableController from "controllers/sortable_table_controller"
import { setupController, click } from "../helpers/stimulus_helper"

describe("SortableTableController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    vi.restoreAllMocks()
  })

  const html = `
    <table data-controller="sortable-table" data-sortable-table-column-value="" data-sortable-table-direction-value="asc">
      <thead>
        <tr>
          <th><a href="#" data-sort-column="name" data-action="click->sortable-table#sort" id="sort-name">Name</a></th>
          <th><a href="#" data-sort-column="price" data-action="click->sortable-table#sort" id="sort-price">Price</a></th>
        </tr>
      </thead>
    </table>
  `

  it("sets aria-sort ascending on first click", async () => {
    window.Turbo = { visit: vi.fn() }
    context = await setupController(SortableTableController, html, "sortable-table")

    click(document.getElementById("sort-name"))
    expect(document.getElementById("sort-name").getAttribute("aria-sort")).toBe("ascending")
  })

  it("toggles to descending on second click of same column", async () => {
    window.Turbo = { visit: vi.fn() }
    context = await setupController(SortableTableController, html, "sortable-table")

    click(document.getElementById("sort-name"))
    click(document.getElementById("sort-name"))
    expect(document.getElementById("sort-name").getAttribute("aria-sort")).toBe("descending")
  })

  it("resets to ascending when switching columns", async () => {
    window.Turbo = { visit: vi.fn() }
    context = await setupController(SortableTableController, html, "sortable-table")

    click(document.getElementById("sort-name"))
    click(document.getElementById("sort-name"))
    click(document.getElementById("sort-price"))

    expect(document.getElementById("sort-price").getAttribute("aria-sort")).toBe("ascending")
    expect(document.getElementById("sort-name").getAttribute("aria-sort")).toBeNull()
  })

  it("calls Turbo.visit when not inside a turbo-frame", async () => {
    window.Turbo = { visit: vi.fn() }
    context = await setupController(SortableTableController, html, "sortable-table")

    click(document.getElementById("sort-name"))
    expect(window.Turbo.visit).toHaveBeenCalledTimes(1)
    expect(window.Turbo.visit).toHaveBeenCalledWith(expect.stringContaining("sort=name"))
  })

  it("sets frame.src when inside a turbo-frame", async () => {
    const framedHtml = `
      <turbo-frame id="products_list">
        <table data-controller="sortable-table" data-sortable-table-column-value="" data-sortable-table-direction-value="asc">
          <thead>
            <tr>
              <th><a href="#" data-sort-column="name" data-action="click->sortable-table#sort" id="sort-name">Name</a></th>
            </tr>
          </thead>
        </table>
      </turbo-frame>
    `
    window.Turbo = { visit: vi.fn() }
    context = await setupController(SortableTableController, framedHtml, "sortable-table")

    click(document.getElementById("sort-name"))
    expect(window.Turbo.visit).not.toHaveBeenCalled()
    const frame = document.querySelector("turbo-frame")
    expect(frame.src).toContain("sort=name")
  })
})
