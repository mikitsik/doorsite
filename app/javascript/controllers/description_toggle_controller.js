import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]
  static classes = ["expanded"]

  connect() {
    requestAnimationFrame(() => {
      this.updateVisibility()
      this.updateButton()
    })
  }

  toggle() {
    this.element.classList.toggle(this.expandedClass)
    this.updateButton()
  }

  updateVisibility() {
    const collapsible =
      this.contentTarget.scrollHeight > this.contentTarget.clientHeight + 1

    this.element.classList.toggle("is-collapsible", collapsible)
    this.buttonTarget.hidden = !collapsible
  }

  updateButton() {
    const expanded = this.element.classList.contains(this.expandedClass)

    this.buttonTarget.textContent = expanded ? "Показать меньше" : "Показать больше"
    this.buttonTarget.setAttribute("aria-expanded", String(expanded))
  }
}
