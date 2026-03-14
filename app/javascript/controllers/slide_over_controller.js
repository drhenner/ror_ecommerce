import { Controller } from "@hotwired/stimulus"

const FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'

export default class extends Controller {
  static targets = ["panel", "overlay"]

  open() {
    this.panelTarget.classList.add("open")
    if (this.hasOverlayTarget) this.overlayTarget.classList.add("open")
    document.addEventListener("keydown", this.handleKeydown)

    requestAnimationFrame(() => {
      const firstFocusable = this.panelTarget.querySelector(FOCUSABLE)
      if (firstFocusable) firstFocusable.focus()
    })
  }

  close() {
    this.panelTarget.classList.remove("open")
    if (this.hasOverlayTarget) this.overlayTarget.classList.remove("open")
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown = (event) => {
    if (event.key === "Escape") {
      this.close()
      return
    }

    if (event.key === "Tab") {
      const focusable = Array.from(this.panelTarget.querySelectorAll(FOCUSABLE))
      if (focusable.length === 0) return

      const first = focusable[0]
      const last = focusable[focusable.length - 1]

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault()
        last.focus()
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault()
        first.focus()
      }
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }
}
