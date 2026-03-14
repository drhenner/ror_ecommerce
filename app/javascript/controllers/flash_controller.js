import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 6000 } }

  connect() {
    this.removing = false
    this.timer = setTimeout(() => this.fadeOut(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timer)
    clearTimeout(this.fallbackTimer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.fadeOut()
  }

  fadeOut() {
    if (this.removing) return
    this.removing = true

    this.element.classList.add("flash-out")
    this.element.addEventListener("animationend", () => {
      this.element.remove()
    }, { once: true })

    this.fallbackTimer = setTimeout(() => this.element.remove(), 1000)
  }
}
