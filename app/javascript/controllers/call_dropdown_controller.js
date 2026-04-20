import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const isOpen = this.element.classList.contains("is-open")

    this.closeAll()

    if (!isOpen) {
      this.element.classList.add("is-open")
      document.addEventListener("click", this.handleOutsideClick)
    }
  }

  close() {
    this.element.classList.remove("is-open")
    document.removeEventListener("click", this.handleOutsideClick)
  }

  closeAll() {
    document.querySelectorAll(".call-dropdown.is-open").forEach((dropdown) => {
      dropdown.classList.remove("is-open")
    })
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }
}
