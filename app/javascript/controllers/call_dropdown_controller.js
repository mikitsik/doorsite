import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.menuElement = this.element.querySelector(".call-dropdown__menu")
    this.buttonElement = this.element.querySelector(".call-dropdown__toggle")

    if (!this.menuElement || !this.buttonElement) return

    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handleWindowChange = this.handleWindowChange.bind(this)

    this.originalParent = this.menuElement.parentNode
    this.originalNextSibling = this.menuElement.nextSibling

    document.addEventListener("click", this.handleDocumentClick)
    window.addEventListener("resize", this.handleWindowChange)
    window.addEventListener("scroll", this.handleWindowChange, true)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick)
    window.removeEventListener("resize", this.handleWindowChange)
    window.removeEventListener("scroll", this.handleWindowChange, true)

    this.close()
    this.restoreMenu()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.hasRequiredElements) return

    const wasOpen = this.isOpen

    this.closeAll()

    if (!wasOpen) this.open()
  }

  open() {
    this.portalMenu()
    this.setOpenState(true)
    this.positionMenu()
  }

  close() {
    this.setOpenState(false)
  }

  closeAll() {
    document.querySelectorAll(".call-dropdown.is-open").forEach((dropdown) => {
      dropdown.classList.remove("is-open")
      dropdown
        .querySelector(".call-dropdown__toggle")
        ?.setAttribute("aria-expanded", "false")
    })

    document.querySelectorAll(".call-dropdown__menu.is-open").forEach((menu) => {
      menu.classList.remove("is-open")
    })
  }

  handleDocumentClick(event) {
    if (
      this.element.contains(event.target) ||
      this.menuElement?.contains(event.target)
    ) {
      return
    }

    this.close()
  }

  handleWindowChange() {
    if (this.isOpen) this.positionMenu()
  }

  portalMenu() {
    if (this.menuElement.parentNode !== document.body) {
      document.body.appendChild(this.menuElement)
    }
  }

  restoreMenu() {
    if (!this.originalParent) return
    if (this.menuElement.parentNode !== document.body) return

    this.originalParent.insertBefore(this.menuElement, this.originalNextSibling)
  }

  positionMenu() {
    if (!this.hasRequiredElements) return

    const buttonRect = this.buttonElement.getBoundingClientRect()
    const gap = 8
    const padding = 16

    this.menuElement.style.left = "0px"
    this.menuElement.style.top = "0px"
    this.menuElement.style.right = "auto"

    const menuRect = this.menuElement.getBoundingClientRect()

    let left = buttonRect.left
    let top = buttonRect.bottom + gap

    left = Math.min(left, window.innerWidth - menuRect.width - padding)
    left = Math.max(left, padding)

    if (top + menuRect.height > window.innerHeight - padding) {
      top = buttonRect.top - menuRect.height - gap
    }

    top = Math.max(top, padding)

    this.menuElement.style.left = `${left}px`
    this.menuElement.style.top = `${top}px`
  }

  setOpenState(value) {
    if (!this.hasRequiredElements) return

    this.element.classList.toggle("is-open", value)
    this.menuElement.classList.toggle("is-open", value)
    this.buttonElement.setAttribute("aria-expanded", String(value))
  }

  get isOpen() {
    return this.element.classList.contains("is-open")
  }

  get hasRequiredElements() {
    return Boolean(this.menuElement && this.buttonElement)
  }
}
