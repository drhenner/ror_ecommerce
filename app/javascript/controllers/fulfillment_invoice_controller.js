import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { invoiceId: Number, orderId: Number, orderUrl: String }

  connect() {
    this.submitting = false
    this.activeAbort = null
  }

  disconnect() {
    if (this.activeAbort) this.activeAbort.abort()
  }

  async capture(event) {
    event.preventDefault()
    if (this.submitting) return
    if (!window.confirm("Are you sure you want to COLLECT FUNDS for this order?")) return
    await this.updateInvoice(event.currentTarget, "PUT", { invoice_id: this.invoiceIdValue, amount: "all" })
  }

  async cancel(event) {
    event.preventDefault()
    if (this.submitting) return
    if (!window.confirm("Are you sure you want to CANCEL the Order and Shipment?")) return
    await this.updateInvoice(event.currentTarget, "DELETE", { invoice_id: this.invoiceIdValue })
  }

  async updateInvoice(button, method, body) {
    this.submitting = true
    if (button) button.disabled = true
    this.activeAbort = new AbortController()

    const url = this.orderUrlValue
    const options = {
      method,
      headers: {
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || "",
        Accept: "text/html",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      signal: this.activeAbort.signal,
    }
    if (body && Object.keys(body).length > 0) {
      options.body = new URLSearchParams(body).toString()
    }
    try {
      const response = await fetch(url, options)
      const html = await response.text()
      const line = document.getElementById(`invoice-line-${this.invoiceIdValue}`)
      if (line && response.ok) line.innerHTML = html
    } catch (e) {
      if (e.name !== "AbortError") console.error(e)
    } finally {
      if (button) button.disabled = false
      this.submitting = false
      this.activeAbort = null
    }
  }
}
