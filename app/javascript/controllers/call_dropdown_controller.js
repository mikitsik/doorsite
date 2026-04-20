import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    this.element.classList.toggle("is-open")
  }

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.element.classList.remove("is-open")
    }
  }
}
