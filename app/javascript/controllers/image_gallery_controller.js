import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "thumbnail", "counter"]
  static values = { index: { type: Number, default: 0 } }

  next() {
    this.indexValue = (this.indexValue + 1) % this.slideTargets.length
  }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.slideTargets.length) % this.slideTargets.length
  }

  goTo(event) {
    this.indexValue = parseInt(event.currentTarget.dataset.index, 10)
  }

  indexValueChanged() {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle("hidden", i !== this.indexValue)
    })

    this.thumbnailTargets.forEach((thumb, i) => {
      thumb.classList.toggle("ring-2", i === this.indexValue)
      thumb.classList.toggle("ring-[var(--color-accent)]", i === this.indexValue)
      thumb.classList.toggle("opacity-50", i !== this.indexValue)
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.indexValue + 1} / ${this.slideTargets.length}`
    }
  }
}
