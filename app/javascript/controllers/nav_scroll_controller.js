import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]
  static classes = ["solid"]

  connect() {
    const hero = document.querySelector("[data-nav-scroll-hero]")
    if (hero) {
      this.barTarget.classList.remove("bg-white", "shadow-md")

      this.observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            this.barTarget.classList.remove("bg-white", "shadow-md")
          } else {
            this.barTarget.classList.add("bg-white", "shadow-md")
          }
        },
        { threshold: 0.1 }
      )
      this.observer.observe(hero)
    }
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
