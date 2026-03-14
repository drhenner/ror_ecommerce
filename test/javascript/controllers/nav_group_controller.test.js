import { describe, it, expect, afterEach } from "vitest"
import NavGroupController from "controllers/nav_group_controller"
import { setupController, click, waitForNextFrame } from "../helpers/stimulus_helper"

describe("NavGroupController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
    localStorage.clear()
  })

  const html = `
    <div data-controller="nav-group" data-nav-group-id-value="orders" data-nav-group-open-value="false">
      <a href="#" data-action="click->nav-group#toggle" id="trigger">Orders</a>
      <div data-nav-group-target="children" style="display:none" id="children">
        <a href="#">Child 1</a>
      </div>
    </div>
  `

  it("opens children on toggle click", async () => {
    context = await setupController(NavGroupController, html, "nav-group")

    click(document.getElementById("trigger"))
    await waitForNextFrame()

    expect(document.getElementById("children").style.display).toBe("block")
  })

  it("closes children on second toggle click", async () => {
    context = await setupController(NavGroupController, html, "nav-group")

    click(document.getElementById("trigger"))
    await waitForNextFrame()
    click(document.getElementById("trigger"))
    await waitForNextFrame()

    expect(document.getElementById("children").style.display).toBe("none")
  })

  it("persists open state to localStorage", async () => {
    context = await setupController(NavGroupController, html, "nav-group")

    click(document.getElementById("trigger"))
    expect(localStorage.getItem("admin-nav-group-orders")).toBe("true")
  })

  it("restores state from localStorage on connect", async () => {
    localStorage.setItem("admin-nav-group-orders", "true")
    context = await setupController(NavGroupController, html, "nav-group")
    await waitForNextFrame()

    expect(document.getElementById("children").style.display).toBe("block")
  })
})
