import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity"]
  static values  = { url: String, current: Number }

  connect() {
    this._debounceTimer = null
  }

  disconnect() {
    if (this._debounceTimer) clearTimeout(this._debounceTimer)
  }

  increment() {
    this.currentValue++
    this.quantityTarget.textContent = this.currentValue
    this._scheduleSave()
  }

  decrement() {
    if (this.currentValue <= 0) return
    this.currentValue--
    this.quantityTarget.textContent = this.currentValue
    if (this.currentValue === 0) {
      this.element.style.opacity = "0.4"
    }
    this._scheduleSave()
  }

  _scheduleSave() {
    if (this._debounceTimer) clearTimeout(this._debounceTimer)
    this._debounceTimer = setTimeout(() => this._save(), 500)
  }

  async _save() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const response = await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token
      },
      body: `quantity=${this.currentValue}`
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }
}
