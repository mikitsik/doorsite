import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["brandField"]

  connect() {
    this.submitDebounced = this.debounce(this.submit.bind(this), 300)
  }

  setBrand(event) {
    const brand = event.currentTarget.dataset.brand || ""

    this.brandFieldTargets.forEach((field) => {
      field.value = brand
      const form = field.form
      if (form) form.requestSubmit()
    })
  }

  submit(event) {
    const form = event.target.form
    if (form) form.requestSubmit()
  }

  debounce(fn, delay) {
    let timeout

    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => fn(...args), delay)
    }
  }
}
