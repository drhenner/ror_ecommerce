import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "link"]
  static values = { basePath: String }

  select() {
    const id = this.selectTarget.value
    if (id) {
      this.linkTarget.href = this.basePathValue.replace("__ID__", id)
      this.linkTarget.style.display = ""
    } else {
      this.linkTarget.style.display = "none"
    }
  }
}
