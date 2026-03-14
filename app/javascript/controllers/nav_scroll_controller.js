import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]
  static classes = ["solid"]

  connect() {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        this.barTarget.classList.toggle(this.solidClass, !entry.isIntersecting)
      },
      { threshold: 0.1 }
    )

    const hero = document.querySelector("[data-nav-scroll-hero]")
    if (hero) {
      this.observer.observe(hero)
    } else {
      this.barTarget.classList.add(this.solidClass)
    }
  }

  disconnect() {
    this.observer.disconnect()
  }
}
