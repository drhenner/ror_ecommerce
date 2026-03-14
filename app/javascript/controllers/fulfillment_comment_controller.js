import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.activeAbort = null
  }

  disconnect() {
    if (this.activeAbort) this.activeAbort.abort()
  }

  async submit(event) {
    event.preventDefault()
    const form = event.target.closest("form") || event.target
    const submitBtn = form.querySelector(".comment-submit-button")
    if (submitBtn) submitBtn.disabled = true

    this.activeAbort = new AbortController()
    const formData = new FormData(form)
    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || "",
          Accept: "application/json",
        },
        signal: this.activeAbort.signal,
      })

      if (!response.ok) return

      const comment = await response.json()
      if (comment.note) {
        const list = this.element.querySelector("#order_comments ul") || document.querySelector("#order_comments ul")
        if (list) {
          const li = document.createElement("li")
          li.textContent = comment.note
          li.appendChild(document.createElement("hr"))
          list.appendChild(li)
        }
        const noteInput = form.querySelector("#comment_note, [name='comment[note]']")
        if (noteInput) noteInput.value = ""
      }
    } catch (e) {
      if (e.name !== "AbortError") console.error("Comment submission failed:", e)
    } finally {
      if (submitBtn) submitBtn.disabled = false
      this.activeAbort = null
    }
  }
}
