import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { index: { type: Number, default: 0 } }

  select(event) {
    event.preventDefault()
    this.indexValue = parseInt(event.currentTarget.dataset.index, 10)
  }

  indexValueChanged() {
    this.tabTargets.forEach((tab, i) => {
      const active = i === this.indexValue
      tab.classList.toggle("border-[var(--color-accent)]", active)
      tab.classList.toggle("text-[var(--color-text)]", active)
      tab.classList.toggle("border-transparent", !active)
      tab.classList.toggle("text-[var(--color-text-muted)]", !active)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== this.indexValue)
    })
  }
}
