import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add(event) {
    event.preventDefault()
    const link = event.currentTarget
    const association = link.dataset.association
    const template = document.getElementById(`${association}_fields_template`)
    if (!template) return

    const escaped = association.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    const content = template.innerHTML.replace(new RegExp(`new_${escaped}`, "g"), new Date().getTime())
    link.parentElement.insertAdjacentHTML("beforebegin", content)
  }

  remove(event) {
    event.preventDefault()
    const link = event.currentTarget
    const wrapper = link.closest(".new_fields") || link.closest(".fields")
    if (!wrapper) return

    const destroyField = wrapper.querySelector('input[type="hidden"][name*="_destroy"]')
    if (destroyField) {
      destroyField.value = "1"
    }

    if (wrapper.classList.contains("new_fields")) {
      wrapper.remove()
    } else {
      wrapper.style.display = "none"
    }
  }
}
