import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["layer"]

  connect() {
    this.duration = 5400
  }

  play(event) {
    event.preventDefault()

    const el = this.layerTarget

    const x = event.clientX
    const y = event.clientY

    el.style.transformOrigin = `${x}px ${y}px`

    el.classList.remove("is-active")
    void el.offsetWidth

    el.classList.add("is-active")

    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      el.classList.remove("is-active")
    }, this.duration)
  }
}
