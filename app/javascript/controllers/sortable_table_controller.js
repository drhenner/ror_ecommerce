import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    column: String,
    direction: { type: String, default: "asc" },
  }

  sort(event) {
    event.preventDefault()
    const link = event.currentTarget
    const column = link.dataset.sortColumn

    if (this.columnValue === column) {
      this.directionValue = this.directionValue === "asc" ? "desc" : "asc"
    } else {
      this.columnValue = column
      this.directionValue = "asc"
    }

    this.updateAriaAttributes()

    const url = new URL(window.location)
    url.searchParams.set("sort", this.columnValue)
    url.searchParams.set("direction", this.directionValue)

    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.src = url.toString()
    } else {
      window.Turbo.visit(url.toString())
    }
  }

  updateAriaAttributes() {
    this.element.querySelectorAll("[data-sort-column]").forEach((el) => {
      el.removeAttribute("aria-sort")
    })

    const active = this.element.querySelector(`[data-sort-column="${this.columnValue}"]`)
    if (active) {
      active.setAttribute("aria-sort", this.directionValue === "asc" ? "ascending" : "descending")
    }
  }
}
