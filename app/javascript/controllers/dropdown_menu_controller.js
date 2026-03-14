import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  show() {
    clearTimeout(this.hideTimer)
    this.menuTarget.classList.remove("hidden")
  }

  hide() {
    this.hideTimer = setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 80)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      clearTimeout(this.hideTimer)
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    this.outsideClickHandler = this.closeOnClickOutside.bind(this)
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    clearTimeout(this.hideTimer)
    document.removeEventListener("click", this.outsideClickHandler)
  }
}
