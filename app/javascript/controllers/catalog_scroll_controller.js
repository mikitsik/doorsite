import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.frame = this.element.querySelector("turbo-frame")

    if (!this.frame) return

    this.handleFrameLoad = this.handleFrameLoad.bind(this)

    this.frame.addEventListener(
      "turbo:frame-load",
      this.handleFrameLoad
    )
  }

  disconnect() {
    if (!this.frame) return

    this.frame.removeEventListener(
      "turbo:frame-load",
      this.handleFrameLoad
    )
  }

  handleFrameLoad() {
    const top =
      this.element.getBoundingClientRect().top +
      window.scrollY -
      12

    window.scrollTo({
      top,
      behavior: "smooth"
    })
  }
}
