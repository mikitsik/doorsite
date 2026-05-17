import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!this.shouldScroll()) return

    this.element.scrollIntoView({
      behavior: "instant",
      block: "start"
    })
  }

  shouldScroll() {
    return document.body.dataset.skipContentScroll !== "true"
  }
}
