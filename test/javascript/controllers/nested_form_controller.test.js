import { describe, it, expect, afterEach } from "vitest"
import NestedFormController from "controllers/nested_form_controller"
import { setupController, click, waitForNextFrame } from "../helpers/stimulus_helper"

describe("NestedFormController", () => {
  let context

  afterEach(() => {
    if (context?.application) context.application.stop()
    document.body.innerHTML = ""
  })

  const html = `
    <div data-controller="nested-form">
      <div class="fields" id="existing-row">
        <input type="hidden" name="order[items][0][_destroy]" value="0" id="destroy-field">
        <span>Existing item</span>
        <a href="#" data-action="click->nested-form#remove" id="remove-existing">Remove</a>
      </div>
      <div class="new_fields" id="new-row">
        <input type="hidden" name="order[items][1][_destroy]" value="0">
        <span>New item</span>
        <a href="#" data-action="click->nested-form#remove" id="remove-new">Remove</a>
      </div>
      <a href="#" data-action="click->nested-form#add" data-association="items" id="add-btn">Add item</a>
      <div id="items_fields_template" style="display:none">
        <div class="new_fields">
          <input type="text" name="order[items][new_items][name]">
        </div>
      </div>
    </div>
  `

  it("adds a new row from template on add click", async () => {
    context = await setupController(NestedFormController, html, "nested-form")

    const countBefore = document.querySelectorAll(".new_fields").length
    click(document.getElementById("add-btn"))
    expect(document.querySelectorAll(".new_fields").length).toBe(countBefore + 1)
  })

  it("replaces template placeholder with timestamp for unique names", async () => {
    context = await setupController(NestedFormController, html, "nested-form")

    click(document.getElementById("add-btn"))
    const allRows = document.querySelectorAll(".new_fields")
    const addedRow = Array.from(allRows).find(
      (row) => !row.closest("#items_fields_template") && row !== document.getElementById("new-row")
    )
    expect(addedRow).toBeDefined()
    const input = addedRow.querySelector("input")
    expect(input.name).not.toContain("new_items")
    expect(input.name).toMatch(/order\[items\]\[\d+\]\[name\]/)
  })

  it("hides existing row and sets _destroy to 1 on remove", async () => {
    context = await setupController(NestedFormController, html, "nested-form")

    click(document.getElementById("remove-existing"))
    const row = document.getElementById("existing-row")
    const destroyField = document.getElementById("destroy-field")
    expect(row.style.display).toBe("none")
    expect(destroyField.value).toBe("1")
  })

  it("completely removes new (unsaved) rows from DOM on remove", async () => {
    context = await setupController(NestedFormController, html, "nested-form")

    expect(document.getElementById("new-row")).not.toBeNull()
    click(document.getElementById("remove-new"))
    expect(document.getElementById("new-row")).toBeNull()
  })

  it("finds _destroy field anywhere in wrapper, not just previous sibling", async () => {
    const deepHtml = `
      <div data-controller="nested-form">
        <div class="fields" id="deep-row">
          <input type="hidden" name="record[items][0][_destroy]" value="0" id="deep-destroy">
          <div class="some-wrapper">
            <span>Content</span>
          </div>
          <a href="#" data-action="click->nested-form#remove" id="deep-remove">Remove</a>
        </div>
      </div>
    `
    context = await setupController(NestedFormController, deepHtml, "nested-form")

    click(document.getElementById("deep-remove"))
    expect(document.getElementById("deep-destroy").value).toBe("1")
    expect(document.getElementById("deep-row").style.display).toBe("none")
  })
})
