import { Application } from "@hotwired/stimulus"

export async function setupController(controllerClass, html, identifier) {
  const name = identifier || controllerClass.name
    .replace(/Controller$/, "")
    .replace(/([a-z])([A-Z])/g, "$1-$2")
    .toLowerCase()

  document.body.innerHTML = html

  const application = Application.start(document.body)
  application.register(name, controllerClass)

  await waitForNextFrame()

  return {
    application,
    get controller() {
      const element = document.querySelector(`[data-controller~="${name}"]`)
      return application.getControllerForElementAndIdentifier(element, name)
    },
    get element() {
      return document.querySelector(`[data-controller~="${name}"]`)
    },
  }
}

export function waitForNextFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

export function click(element) {
  element.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }))
}

export function keydown(element, key, options = {}) {
  element.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true, ...options }))
}

export function type(element, value) {
  element.value = value
  element.dispatchEvent(new Event("input", { bubbles: true }))
}
