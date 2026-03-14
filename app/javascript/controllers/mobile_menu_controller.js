import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.beforeVisitHandler = () => this.close()
    document.addEventListener("turbo:before-visit", this.beforeVisitHandler)
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("turbo:before-visit", this.beforeVisitHandler)
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    document.body.classList.toggle("overflow-hidden", !this.menuTarget.classList.contains("hidden"))
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
