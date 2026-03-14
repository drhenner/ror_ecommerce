import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 6000 } }

  connect() {
    this.removed = false
    this.timer = setTimeout(() => this.fadeOut(), this.delayValue)
  }

  disconnect() {
    this.removed = true
    clearTimeout(this.timer)
    clearTimeout(this.fallbackTimer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.fadeOut()
  }

  fadeOut() {
    if (this.removed) return
    this.removed = true

    this.element.classList.add("flash-out")
    this.element.addEventListener("animationend", () => {
      this.element.remove()
    }, { once: true })

    this.fallbackTimer = setTimeout(() => {
      if (this.element.parentNode) this.element.remove()
    }, 1000)
  }
}
