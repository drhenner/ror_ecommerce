import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["box"]

  connect() {
    this.submitting = false
    this.activeAbort = null
  }

  disconnect() {
    if (this.activeAbort) this.activeAbort.abort()
  }

  async create(event) {
    event.preventDefault()
    if (this.submitting) return
    this.submitting = true

    const button = event.currentTarget
    const url = button.dataset.url
    if (!url) { this.submitting = false; return }

    this.activeAbort = new AbortController()
    button.disabled = true
    try {
      const response = await fetch(url, {
        method: "PUT",
        headers: {
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || "",
          Accept: "text/html",
        },
        signal: this.activeAbort.signal,
      })
      if (response.ok) {
        const html = await response.text()
        const target = this.hasBoxTarget ? this.boxTarget : document.querySelector("#shipment-details-box")
        if (target) target.innerHTML = html
      }
    } catch (e) {
      if (e.name !== "AbortError") console.error(e)
    } finally {
      button.disabled = false
      this.submitting = false
      this.activeAbort = null
    }
  }
}
