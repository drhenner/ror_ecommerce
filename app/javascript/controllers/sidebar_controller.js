import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "nav"]
  static values = { storageKey: { type: String, default: "admin-sidebar-collapsed" } }

  connect() {
    const collapsed = localStorage.getItem(this.storageKeyValue) === "true"
    if (collapsed) {
      document.body.classList.add("sidebar-collapsed")
    }
  }

  toggle() {
    if (window.innerWidth <= 768) {
      document.body.classList.toggle("sidebar-open")
    } else {
      document.body.classList.toggle("sidebar-collapsed")
      localStorage.setItem(
        this.storageKeyValue,
        document.body.classList.contains("sidebar-collapsed")
      )
    }
  }

  close() {
    document.body.classList.remove("sidebar-open")
  }
}
