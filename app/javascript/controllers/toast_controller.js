import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-hide toast after 5 seconds
    setTimeout(() => {
      this.hide()
    }, 5000)
  }

  hide() {
    this.element.classList.add('opacity-0', 'translate-x-full')

    // Remove element after transition
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  close() {
    this.hide()
  }
}
