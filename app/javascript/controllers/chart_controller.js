import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: { type: String, default: "bar" },
    data: Object,
    options: { type: Object, default: {} },
  }

  connect() {
    this.connected = true
    this.renderChart()
  }

  disconnect() {
    this.connected = false
    this.destroyChart()
  }

  dataValueChanged() {
    if (!this.connected) return
    this.destroyChart()
    this.renderChart()
  }

  renderChart() {
    if (!this.dataValue || Object.keys(this.dataValue).length === 0) {
      this.renderPlaceholder()
      return
    }

    this.renderSimpleBarChart()
  }

  renderSimpleBarChart() {
    const data = this.dataValue
    const labels = data.labels || []
    const values = data.values || []
    if (labels.length === 0) return

    const maxVal = Math.max(...values, 1)
    const barWidth = Math.floor(100 / labels.length)

    const container = document.createElement("div")
    container.style.cssText = "display:flex;align-items:flex-end;justify-content:space-around;height:200px;padding:8px 0"

    values.forEach((v, i) => {
      const height = Math.round((v / maxVal) * 100)
      const col = document.createElement("div")
      col.style.cssText = `display:inline-flex;flex-direction:column;align-items:center;width:${barWidth}%;gap:4px`

      const valLabel = document.createElement("span")
      valLabel.style.cssText = "font-size:11px;color:var(--color-text-muted)"
      valLabel.textContent = v

      const bar = document.createElement("div")
      bar.style.cssText = `width:60%;height:${height}px;background:var(--color-accent);border-radius:4px 4px 0 0;min-height:2px`

      const nameLabel = document.createElement("span")
      nameLabel.style.cssText = "font-size:11px;color:var(--color-text-muted)"
      nameLabel.textContent = labels[i]

      col.append(valLabel, bar, nameLabel)
      container.appendChild(col)
    })

    this.element.innerHTML = ""
    this.element.appendChild(container)
  }

  renderPlaceholder() {
    const placeholder = document.createElement("div")
    placeholder.style.cssText = "display:flex;align-items:center;justify-content:center;height:200px;color:var(--color-text-muted);font-size:13px"
    placeholder.textContent = "No chart data available"
    this.element.innerHTML = ""
    this.element.appendChild(placeholder)
  }

  destroyChart() {
    this.element.innerHTML = ""
  }
}
