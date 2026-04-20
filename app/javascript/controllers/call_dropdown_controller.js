import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("click", this.handleDocumentClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const isOpen = this.element.classList.contains("is-open")

    this.closeAll()

    if (!isOpen) {
      this.element.classList.add("is-open")
      this.setExpanded(true)
    }
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  close() {
    this.element.classList.remove("is-open")
    this.setExpanded(false)
  }

  closeAll() {
    document.querySelectorAll(".call-dropdown.is-open").forEach((dropdown) => {
      dropdown.classList.remove("is-open")

      const button = dropdown.querySelector(".call-dropdown__toggle")
      if (button) button.setAttribute("aria-expanded", "false")
    })
  }

  setExpanded(value) {
    const button = this.element.querySelector(".call-dropdown__toggle")
    if (button) button.setAttribute("aria-expanded", String(value))
  }
}
