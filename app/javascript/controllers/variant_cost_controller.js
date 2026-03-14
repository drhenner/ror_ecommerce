import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.activeAbort = null
  }

  disconnect() {
    if (this.activeAbort) this.activeAbort.abort()
  }

  change(event) {
    const select = event.currentTarget
    const variantId = select.value
    if (!variantId) return

    const costInput = this.findCostInput(select)
    if (!costInput) return

    if (this.activeAbort) this.activeAbort.abort()
    this.activeAbort = new AbortController()

    const url = this.urlValue.replace(/\/?$/, "") + "/" + encodeURIComponent(variantId)
    fetch(url, {
      headers: { Accept: "application/json" },
      signal: this.activeAbort.signal,
    })
      .then((res) => {
        if (!res.ok) return null
        return res.json()
      })
      .then((variant) => {
        if (variant && variant.cost != null) costInput.value = variant.cost
      })
      .catch((e) => {
        if (e.name !== "AbortError") console.error("Variant cost fetch failed:", e)
      })
      .finally(() => {
        this.activeAbort = null
      })
  }

  findCostInput(select) {
    const row = select.closest(".variant-row, .fields, .new_fields, [data-variant-cost-target]")
    if (!row) return null
    return row.querySelector('input[name*="[cost]"]')
  }
}
