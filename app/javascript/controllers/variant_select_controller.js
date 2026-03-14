import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variantButton", "variantId", "properties", "stock", "form"]
  static values = { submitting: { type: Boolean, default: false } }

  connect() {
    if (this.hasVariantButtonTarget) {
      if (!this.variantIdTarget.value) {
        this.variantIdTarget.value = this.variantButtonTargets[0]?.dataset.variantId
      }
      this.syncVisuals()
    }
  }

  select(event) {
    this.variantIdTarget.value = event.currentTarget.dataset.variantId
    this.syncVisuals()
  }

  addToCart(event) {
    event.preventDefault()
    if (!this.variantIdTarget.value) {
      alert("Please click on a specific item to add.")
      return
    }
    if (this.submittingValue) return
    this.submittingValue = true

    this.formTarget.addEventListener("turbo:submit-end", () => {
      this.submittingValue = false
    }, { once: true })

    this.formTarget.requestSubmit()
  }

  syncVisuals() {
    const variantId = this.variantIdTarget.value
    if (!variantId) return

    this.variantButtonTargets.forEach((btn) => {
      const isSelected = btn.dataset.variantId === variantId
      btn.classList.toggle("bg-[var(--color-accent)]", isSelected)
      btn.classList.toggle("text-white", isSelected)
      btn.classList.toggle("bg-[var(--color-highlight)]", !isSelected)
      btn.classList.toggle("text-[var(--color-text)]", !isSelected)
    })

    this.propertiesTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.variantId !== variantId)
    })

    this.stockTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.variantId !== variantId)
    })
  }
}
