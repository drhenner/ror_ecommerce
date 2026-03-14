import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["children"]
  static values = {
    id: String,
    open: { type: Boolean, default: false },
  }

  connect() {
    const stored = localStorage.getItem(this.storageKey)
    if (stored !== null) {
      this.openValue = stored === "true"
    }
  }

  toggle(event) {
    event.preventDefault()
    this.openValue = !this.openValue
    localStorage.setItem(this.storageKey, this.openValue)
  }

  openValueChanged() {
    if (this.hasChildrenTarget) {
      this.childrenTarget.style.display = this.openValue ? "block" : "none"
    }
  }

  get storageKey() {
    return `admin-nav-group-${this.idValue}`
  }
}
