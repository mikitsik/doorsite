import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brandField"]

  connect() {
    this.submitLater = this.debounce(() => {
      const form = this.element.tagName === "FORM" ? this.element : this.element.querySelector("form")
      if (form) form.requestSubmit()
    }, 300)
  }

  setBrand(event) {
    const brand = event.currentTarget.dataset.brand || ""

    this.brandFieldTargets.forEach((field) => {
      field.value = brand
      const form = field.form
      if (form) form.requestSubmit()
    })
  }

  submitDebounced() {
    this.submitLater()
  }

  debounce(fn, delay) {
    let timeout

    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => fn(...args), delay)
    }
  }
}
