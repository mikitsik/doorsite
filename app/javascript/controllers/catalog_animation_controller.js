import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["layer"]

  connect() {
    this.duration = 6480
  }

  play(event) {
    event.preventDefault()

    const el = this.layerTarget
    const mode = event.currentTarget.dataset.catalogAnimationMode

    const x = event.clientX
    const y = event.clientY

    el.style.left = `${x}px`
    el.style.top = `${y}px`

    el.classList.toggle("is-section", mode === "section")
    el.classList.remove("is-active")
    void el.offsetWidth

    el.classList.add("is-active")

    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      el.classList.remove("is-active")
    }, this.duration)
  }
}
