import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden"]
  static values = { url: String, minLength: { type: Number, default: 2 } }

  connect() {
    this.selectedIndex = -1
    this.abortController = null
    this.debounceTimer = null
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
    this.closeResults()
    if (this.abortController) this.abortController.abort()
    clearTimeout(this.debounceTimer)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeResults()
    }
  }

  onInput() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.closeResults()
      return
    }

    this.debounceTimer = setTimeout(() => this.fetchResults(query), 250)
  }

  async fetchResults(query) {
    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("q", query)

      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal,
      })

      if (!response.ok) return

      const items = await response.json()
      this.renderResults(items)
    } catch (e) {
      if (e.name !== "AbortError") throw e
    }
  }

  renderResults(items) {
    this.selectedIndex = -1

    if (items.length === 0) {
      this.closeResults()
      return
    }

    this.resultsTarget.innerHTML = ""
    items.forEach((item, i) => {
      const div = document.createElement("div")
      div.className = "autocomplete-item"
      div.dataset.index = i
      div.dataset.value = String(item.value ?? "")
      div.dataset.label = String(item.label ?? "")
      div.dataset.action = "click->autocomplete#select mouseenter->autocomplete#highlight"
      div.textContent = item.label ?? ""
      this.resultsTarget.appendChild(div)
    })

    this.resultsTarget.style.display = "block"
  }

  select(event) {
    const item = event?.currentTarget || this.resultsTarget.children[this.selectedIndex]
    if (!item) return

    this.inputTarget.value = item.dataset.label
    if (this.hasHiddenTarget) this.hiddenTarget.value = item.dataset.value
    this.closeResults()
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  highlight(event) {
    this.selectedIndex = parseInt(event.currentTarget.dataset.index, 10)
    this.updateHighlight()
  }

  onKeydown(event) {
    if (!this.resultsTarget.style.display || this.resultsTarget.style.display === "none") return

    const items = this.resultsTarget.children
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateHighlight()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.updateHighlight()
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0) this.select()
        break
      case "Escape":
        this.closeResults()
        break
    }
  }

  updateHighlight() {
    Array.from(this.resultsTarget.children).forEach((el, i) => {
      el.classList.toggle("highlighted", i === this.selectedIndex)
    })
  }

  closeResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.style.display = "none"
      this.resultsTarget.innerHTML = ""
    }
    this.selectedIndex = -1
  }

}
