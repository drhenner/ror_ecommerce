import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: { type: String, default: "Are you sure?" } }

  confirm(event) {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
