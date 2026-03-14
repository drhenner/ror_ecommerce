import { describe, it, expect, beforeEach, afterEach } from "vitest"
import SidebarController from "controllers/sidebar_controller"
import { setupController, click } from "../helpers/stimulus_helper"

describe("SidebarController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    document.body.className = ""
    localStorage.clear()
  })

  const html = `
    <div data-controller="sidebar">
      <button data-action="click->sidebar#toggle" id="toggle-btn"></button>
      <button data-action="click->sidebar#close" id="close-btn"></button>
    </div>
  `

  it("adds sidebar-collapsed class on toggle (desktop)", async () => {
    Object.defineProperty(window, "innerWidth", { value: 1024, writable: true })
    context = await setupController(SidebarController, html, "sidebar")

    click(document.getElementById("toggle-btn"))
    expect(document.body.classList.contains("sidebar-collapsed")).toBe(true)
  })

  it("persists collapsed state to localStorage", async () => {
    Object.defineProperty(window, "innerWidth", { value: 1024, writable: true })
    context = await setupController(SidebarController, html, "sidebar")

    click(document.getElementById("toggle-btn"))
    expect(localStorage.getItem("admin-sidebar-collapsed")).toBe("true")
  })

  it("restores collapsed state from localStorage on connect", async () => {
    localStorage.setItem("admin-sidebar-collapsed", "true")
    Object.defineProperty(window, "innerWidth", { value: 1024, writable: true })
    context = await setupController(SidebarController, html, "sidebar")

    expect(document.body.classList.contains("sidebar-collapsed")).toBe(true)
  })

  it("toggles sidebar-open on mobile", async () => {
    Object.defineProperty(window, "innerWidth", { value: 600, writable: true })
    context = await setupController(SidebarController, html, "sidebar")

    click(document.getElementById("toggle-btn"))
    expect(document.body.classList.contains("sidebar-open")).toBe(true)
  })

  it("close removes sidebar-open class", async () => {
    Object.defineProperty(window, "innerWidth", { value: 600, writable: true })
    context = await setupController(SidebarController, html, "sidebar")

    document.body.classList.add("sidebar-open")
    click(document.getElementById("close-btn"))
    expect(document.body.classList.contains("sidebar-open")).toBe(false)
  })
})
