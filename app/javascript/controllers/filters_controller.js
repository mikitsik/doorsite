import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  toggle() {
    this.panelTarget.classList.toggle("is-open")
    this.buttonTarget.classList.toggle("is-open")
  }
}
